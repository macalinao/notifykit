# NotifyKit Development Notes

## Building

### App Bundle

Always run `cargo bundle` from the **workspace root**, not from `crates/notifykit/`:

```bash
# Correct - from workspace root
cargo bundle --release -p notifykit

# Wrong - will not include resources
cd crates/notifykit && cargo bundle --release
```

This is because `cargo-bundle` resolves resource paths relative to the current working directory, not the Cargo.toml location. The `resources/` directory is at the workspace root.

### Verify Bundle

After building, verify the bundle includes all resources:

```bash
./scripts/verify-bundle-resources.sh
```
