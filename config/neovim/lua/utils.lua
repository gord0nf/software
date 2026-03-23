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
}
