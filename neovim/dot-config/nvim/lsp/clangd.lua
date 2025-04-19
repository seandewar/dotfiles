return {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- GNU Autotools.
  },
  capabilities = {
    -- Off-spec, but clangd and vim.lsp support UTF-8, which is more efficient.
    offsetEncoding = { "utf-8", "utf-16" },
  },
} --[[@as vim.lsp.Config]]
