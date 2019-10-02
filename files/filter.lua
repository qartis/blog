function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      io.stderr:write(formatting .. "\n")
      tprint(v, indent+1)
    else
      io.stderr:write(formatting .. v .. "\n")
    end
  end
end

local function abc2svg(abc)
    local svg = pandoc.pipe("abcm2ps", {"-g", "-q", "-O", "-", "-"}, abc)
    return svg
end

local function dot2svg(dot)
    local svg = pandoc.pipe("dot", {"-Tsvg"}, dot)
    return svg
end

local function getname(attr_list, def)
    for key, value in pairs(attr_list) do
        if key == "name" then
            return value
        end
    end
    return nil
end

function CodeBlock(block)
    if block.classes[1] == "abc" then
        local name = getname(block.attributes) or "music"
        local img = abc2svg(block.text)
        local fname = getname(block.attributes) .. ".svg" or pandoc.sha1(img) .. ".svg"
        pandoc.mediabag.insert(fname, "image/svg+xml", img)
        local imgObj = pandoc.Image({pandoc.Str(name)}, fname)
        local divObj = pandoc.Div{pandoc.Plain{imgObj}}
	divObj.classes = {"figure"}
	return divObj
    elseif block.classes[1] == "dot" then
        local name = getname(block.attributes) or "graphviz graph"
        local img = dot2svg(block.text)
        local fname = getname(block.attributes) .. ".svg" or pandoc.sha1(img) .. ".svg"
        pandoc.mediabag.insert(fname, "image/svg+xml", img)
        local imgObj = pandoc.Image({pandoc.Str("graphviz graph")}, fname)
        local divObj = pandoc.Div{pandoc.Plain{imgObj}}
	divObj.classes = {"figure"}
	return divObj
    end
end





function Para(f)
  if #f.content ~= 7 then
    return f
  end

  local field_name = f.content[1].text
  local field = f.content[3].text
  local bits_name = f.content[5].text
  local bits = f.content[7].text

  if not string.match(field_name, "^%l+:$") or not string.match(bits_name, "^%l+:$") then
    return f
  end

  local c = nil
  local blocks = {}
  local bitstr = ''
  for i = 1, #field do
    if field:sub(i,i)~= c then
      if c then
        table.insert(blocks,pandoc.Span(bitstr, pandoc.Attr('',{c})))
      end
      c = field:sub(i,i)
      bitstr = ''
    end
    bitstr = bitstr .. bits:sub(i,i)
  end
  if bitstr then
    table.insert(blocks,pandoc.Span(bitstr, pandoc.Attr('',{c})))
  end
    
  return pandoc.Para(blocks)
end
