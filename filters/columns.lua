-- columns.lua
-- Pandoc Lua filter: converts two-column div layouts for PPTX output.
--
-- Usage in markdown:
--
--   ::::: {.columns}
--   :::: {.column width="50%"}
--   Left content here
--   ::::
--   :::: {.column width="50%"}
--   Right content here
--   ::::
--   :::::
--
-- For Beamer (PDF), pandoc handles .columns/.column natively.
-- This filter ensures correct behaviour for PPTX output via
-- PowerPoint's two-content layout.

local function is_columns(div)
  return div.classes:includes("columns")
end

local function is_column(div)
  return div.classes:includes("column")
end

-- For non-Beamer output: flatten columns into side-by-side blocks.
-- Pandoc's PPTX writer uses the two-content layout when the slide
-- body contains exactly two top-level block sequences.  We emit a
-- RawBlock separator that pandoc's PPTX writer recognises as a
-- column break between the two content areas.
function Div(div)
  if FORMAT == "beamer" then
    -- Beamer handles .columns/.column natively — pass through untouched.
    return nil
  end

  if not is_columns(div) then
    return nil
  end

  local columns = {}
  for _, block in ipairs(div.content) do
    if block.t == "Div" and is_column(block) then
      columns[#columns + 1] = block.content
    end
  end

  if #columns < 2 then
    -- Not a two-column layout; leave as-is.
    return nil
  end

  -- Build a flat list: left blocks, then a column-break, then right blocks.
  local result = {}
  for _, blk in ipairs(columns[1]) do
    result[#result + 1] = blk
  end
  -- PPTX column separator: an empty paragraph with a special class.
  -- pandoc's PPTX writer does not have a native column break, so we
  -- emit both columns as sequential content inside a Para each.
  -- The cleanest approach for pptx is to leave two div blocks which
  -- pandoc maps to the "Two Content" slide layout.
  -- We reconstruct the div with exactly the two column divs as direct
  -- children so pandoc's pptx writer can identify and map them.
  local left  = pandoc.Div(columns[1], pandoc.Attr("", {"column"}))
  local right = pandoc.Div(columns[2], pandoc.Attr("", {"column"}))
  return pandoc.Div({left, right}, pandoc.Attr("", {"columns"}))
end
