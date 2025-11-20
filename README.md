# Aiorunner

Tiny wrapper around `asyncio` that starts long running tasks, installs
`SIGINT`/`SIGTERM` handlers, and guarantees a single cleanup point for your
application.

## Highlights

- registers `SIGINT` and `SIGTERM` handlers so `Ctrl+C` or an orchestrator can
  stop the loop cleanly;
- validates that the provided context function is an async generator with one
  `yield`, otherwise raises `RuntimeError`;
- exposes `Runner.stop()` so any coroutine can request shutdown;
- forwards the `debug` flag to `asyncio.run` for richer diagnostics.

## Installation

```bash
pip install aiorunner
```

Requires Python 3.11-3.13 (see `pyproject.toml`).

## Quick start

```python
import asyncio
from collections.abc import AsyncIterator
from aiorunner import Runner


async def app(runner: Runner) -> AsyncIterator[None]:
    task = asyncio.create_task(asyncio.sleep(3600))
    print("Ready")
    yield  # blocks until Ctrl+C or runner.stop()
    task.cancel()
    print("Bye")


Runner(app, debug=True).run()
```

Inside your context function:

1. Prepare resources before `yield` (servers, background tasks, DB pools).
2. `yield` once. A second `yield` triggers `RuntimeError`.
3. After `yield`, perform cleanup. Calling `runner.stop()` before `run()` or
   after shutdown raises `RuntimeError` to help catch lifecycle bugs.

## API surface

```python
Runner(
    context_function: ContextFunction,
    *,
    debug: bool = False,
    **kwargs: Any,
)
```

- `context_function` must be `async def context(runner, **kwargs) -> AsyncIterator[None]`.
- `debug` toggles `asyncio.run(..., debug=True)`.
- `**kwargs` are forwarded to the context function.

Methods:

- `run()` starts the event loop and blocks until cleanup finishes.
- `stop()` can be scheduled from any task or thread via.

## Observability

The package logger `aiorunner` logs `DEBUG` messages when entering the wait
loop, receiving a signal, and exiting cleanup. Configure logging handlers in
your app to surface these breadcrumbs.

## Development

- Create/update the virtual environment with `uv sync --group dev`; this keeps
  `.venv` aligned with `uv.lock`.
- Automation lives in `mise.toml`; run `mise run lint`, `mise run basedpyright`,
  `mise run mypy`, `mise run test`, or the umbrella `mise run all` to reuse the
  exact CI commands.
- Hook runner: we lean on [prek](https://github.com/j178/prek) with the same
  `.pre-commit-config.yaml` used in CI. Install it via `uvx prek install` and
  run `uvx prek run --all` (or `uvx prek run basedpyright`, etc.) before
  committing.
- Additional helpers exist as `mise run format`, `mise run coverage`,
  `mise run build`, and `mise run upload` for releases.
- `tox` targets `py311`, `py312`, `py313`, and `lint` so CI can mirror local
  runs.

## License

MIT, see `LICENSE`.
