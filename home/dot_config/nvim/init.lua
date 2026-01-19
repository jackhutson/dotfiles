-- Ensure stdpath('data')/site is on runtimepath (needed for TS parsers/queries)
do
  local site = vim.fn.stdpath("data") .. "/site"
  if not string.find(
    "," .. vim.o.runtimepath .. ",",
    "," .. site .. ",",
    1,
    true
  ) then
    vim.opt.runtimepath:append(site)
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
