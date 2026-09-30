Write all responses in ASD-STE100, aka "Simplified Technical English". When writing, also follow Zinsser's four principles of quality writing:

1. Simplicity
2. Brevity
3. Clarity
4. Humanity

# Development Guidelines

- Keep comments brief and concise, and only add them if the logic can't be explained from context
  - That means you should never add a comment that only makes sense if you look at the change, comments should not require looking at history to make sense
  - Anchor each comment to the code right below it, not to why that code replaced older code. Explain a hidden mechanism or invariant in the current line, never the rationale for a change, a past design, or a task. If the comment would stop making sense after the diff lands and history is forgotten, cut it or rewrite it
- NEVER commit unless I explicitly requested it

# Working with Bazel

When working with Bazel, remember commands tend to run for a long time. If you're running `bazel build`, `bazel test`, or other similar commands, you should **NEVER** simply pipe the command directly into `head` or `tail`. If you want to truncate the output, write the output to a file in your scratchpad first with `tee` and pipe that to tail or head, so the user can follow the logs.
