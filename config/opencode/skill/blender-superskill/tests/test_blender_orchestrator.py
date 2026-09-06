import contextlib
import importlib.util
import io
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "scripts" / "blender_orchestrator.py"
SPEC = importlib.util.spec_from_file_location("blender_orchestrator", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def invoke(*args: str) -> tuple[int, str]:
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        try:
            code = MODULE.main(list(args))
        except SystemExit as exc:
            code = exc.code if isinstance(exc.code, int) else 2
    return code, output.getvalue()


def write_submission(path: Path, prompt_id: str, result: object) -> None:
    path.write_text(json.dumps({"prompt_id": prompt_id, "result": result}), encoding="utf-8")


def plan_result() -> dict:
    return {
        "status": "ok",
        "view_analysis": {"angle": "front"},
        "anatomy": {"body": "tower"},
        "proportions": [
            {"name": "height", "target": "4x width", "evidence": "reference"},
            {"name": "roof", "target": "0.25 height", "evidence": "reference"},
            {"name": "base", "target": "0.5 width", "evidence": "reference"},
        ],
        "steps": [{
            "id": "S01", "title": "body", "objective": "build body",
            "reference_features": ["silhouette"], "anchors": ["base"],
            "forbidden": [], "required_inspections": ["front"], "pass_criteria": ["aligned"],
        }],
        "risks": [],
    }


def build_result(step_id: str, status: str = "pass") -> dict:
    return {
        "status": status, "step_id": step_id, "attempt": 1,
        "objects_created": ["body"], "objects_modified": [], "anchors_used": ["base"],
        "inspections_done": ["front"], "screenshots": ["front.png"],
        "reference_comparison": {"matches": ["silhouette"], "mismatches": [], "proportion_checks": [{"name": "height"}]},
        "remaining_differences": [{"issue": "minor"}], "coverage_updates": [],
        "why_acceptable_to_continue": "measured and minor", "next_action": "advance",
    }


def final_result(status: str = "complete") -> dict:
    return {
        "status": status, "top_differences": [{"issue": "minor"}], "missing_features": [],
        "repair_steps": [] if status == "complete" else [{"id": "R01", "title": "repair", "objective": "fix proportion"}],
        "final_checks": ["six sides"], "next_action": "complete" if status == "complete" else "add_repairs",
    }


class OrchestratorCliTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "runs"
        self.workspace = Path(self.temp.name) / "project"
        self.workspace.mkdir()

    def tearDown(self) -> None:
        self.temp.cleanup()

    def cli(self, *args: str) -> tuple[int, str]:
        return invoke("--workspace", str(self.workspace), "--run-root", str(self.root), *args)

    def prepare(self) -> tuple[Path, str]:
        code, _ = self.cli("prepare", "tower")
        self.assertEqual(code, 0)
        state = json.loads((self.root / "tower" / "state.json").read_text())
        return self.root / "tower", state["active_prompt_id"]

    def submit(self, run_dir: Path, prompt_id: str, result: object) -> int:
        path = run_dir / "submission.json"
        write_submission(path, prompt_id, result)
        code, _ = self.cli("submit", str(path), "tower", "--prompt-id", prompt_id)
        return code

    def test_init_rejects_existing_and_traversal_without_deleting(self):
        outside = self.root.parent / "keep"
        outside.write_text("keep")
        code, _ = self.cli("init", "--task", "x", "--name", "invalid-retries", "--max-retries-per-step", "0")
        self.assertNotEqual(code, 0)
        code, _ = self.cli("init", "--task", "x", "--name", "../keep")
        self.assertNotEqual(code, 0)
        self.assertEqual(outside.read_text(), "keep")
        code, _ = self.cli("init", "--task", "x", "--name", "safe")
        self.assertEqual(code, 0)
        code, _ = self.cli("init", "--task", "x", "--name", "safe")
        self.assertNotEqual(code, 0)
        self.assertTrue((self.root / "safe" / "state.json").exists())

    def test_valid_lifecycle_with_repair_and_final_review(self):
        code, _ = self.cli("init", "--task", "tower", "--name", "tower")
        self.assertEqual(code, 0)
        run_dir, prompt_id = self.prepare()
        self.assertEqual(self.submit(run_dir, prompt_id, plan_result()), 0)
        _, prompt_id = self.prepare()
        self.assertEqual(self.submit(run_dir, prompt_id, build_result("S01")), 0)
        _, prompt_id = self.prepare()
        self.assertEqual(self.submit(run_dir, prompt_id, final_result("needs_repair")), 0)
        _, prompt_id = self.prepare()
        self.assertEqual(self.submit(run_dir, prompt_id, build_result("R01")), 0)
        _, prompt_id = self.prepare()
        self.assertEqual(self.submit(run_dir, prompt_id, final_result()), 0)
        state = json.loads((run_dir / "state.json").read_text())
        self.assertEqual(state["phase"], "complete")

    def test_malformed_nested_result_is_rejected_without_state_change(self):
        code, _ = self.cli("init", "--task", "tower", "--name", "tower")
        self.assertEqual(code, 0)
        run_dir, prompt_id = self.prepare()
        before = (run_dir / "state.json").read_text()
        self.assertNotEqual(self.submit(run_dir, prompt_id, {"status": ["not-a-string"]}), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)
        malformed_plan = plan_result()
        malformed_plan["steps"] = [1]
        self.assertNotEqual(self.submit(run_dir, prompt_id, malformed_plan), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)
        self.assertEqual(self.submit(run_dir, prompt_id, plan_result()), 0)
        _, build_prompt_id = self.prepare()
        before = (run_dir / "state.json").read_text()
        malformed_build = build_result("S01")
        malformed_build["status"] = []
        self.assertNotEqual(self.submit(run_dir, build_prompt_id, malformed_build), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)
        submission = run_dir / "list.json"
        submission.write_text("[]", encoding="utf-8")
        code, _ = self.cli("submit", str(submission), "tower", "--prompt-id", build_prompt_id)
        self.assertNotEqual(code, 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)
        malformed_build["status"] = "pass"
        self.assertEqual(self.submit(run_dir, build_prompt_id, malformed_build), 0)
        _, final_prompt_id = self.prepare()
        before = (run_dir / "state.json").read_text()
        malformed_final = final_result("needs_repair")
        malformed_final["repair_steps"][0]["id"] = "../unsafe"
        self.assertNotEqual(self.submit(run_dir, final_prompt_id, malformed_final), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)

    def test_valid_blocked_submission_has_failure_status(self):
        self.cli("init", "--task", "tower", "--name", "tower")
        run_dir, prompt_id = self.prepare()
        blocked = dict(plan_result())
        blocked["status"] = "blocked"
        blocked["blocker"] = "reference unavailable"
        code = self.submit(run_dir, prompt_id, blocked)
        self.assertNotEqual(code, 0)
        state = json.loads((run_dir / "state.json").read_text())
        self.assertEqual(state["phase"], "blocked")

    def test_stale_and_duplicate_submissions_and_terminal_rejection(self):
        self.cli("init", "--task", "tower", "--name", "tower")
        run_dir, prompt_id = self.prepare()
        submission = run_dir / "submission.json"
        write_submission(submission, "stale", plan_result())
        code, _ = self.cli("submit", str(submission), "tower", "--prompt-id", "stale")
        self.assertNotEqual(code, 0)
        self.assertEqual(self.submit(run_dir, prompt_id, plan_result()), 0)
        before = (run_dir / "state.json").read_text()
        self.assertNotEqual(self.submit(run_dir, prompt_id, build_result("S01")), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)
        _, next_id = self.prepare()
        self.assertEqual(self.submit(run_dir, next_id, build_result("S01")), 0)
        _, next_id = self.prepare()
        self.assertEqual(self.submit(run_dir, next_id, final_result()), 0)
        before = (run_dir / "state.json").read_text()
        self.assertNotEqual(self.submit(run_dir, next_id, final_result()), 0)
        self.assertEqual((run_dir / "state.json").read_text(), before)


if __name__ == "__main__":
    unittest.main()
