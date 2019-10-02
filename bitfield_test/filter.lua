require('tprint')

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
  if f.content[1].text ~= "field:" or f.content[5].text ~= "bits:" then
    return f
  end
  field = f.content[3].text
  bits = f.content[7].text
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
