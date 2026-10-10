return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = { command = "clippy" },
      cargo = { allFeatures = true },
    },
  },
}
