return {
  merge_tables = function(t1, t2)
    if type(t1) ~= 'table' or type(t2) ~= 'table' then
      return
    end
    for k, v in pairs(t2) do
      t1[k] = v
    end
  end,
  concat_tables = function(a1, a2)
    if type(a1) ~= 'table' or type(a2) ~= 'table' then
      return
    end
    for _, v in ipairs(a2) do
      a1[#a1 + 1] = v
    end
  end,
  list_subdirs = function(dir)
    local subdirs = {}
    local entries = vim.fn.readdir(dir)

    if entries then
      for _, entry in pairs(entries) do
        local full_path = vim.fs.joinpath(dir, entry)
        if vim.fn.isdirectory(full_path) == 1 then
          table.insert(subdirs, entry)
        end
      end
    end

    return subdirs
  end,
  index_of = function(a, target)
    for idx, value in ipairs(a) do
      if value == target then
        return idx
      end
    end
    return -1
  end,
  extend_or_override = function(config, custom, ...)
    if type(custom) == 'function' then
      config = custom(config, ...) or config
    elseif custom then
      config = vim.tbl_deep_extend('force', config, custom) --[[@as table]]
    end
    return config
  end,
}
