local TEST_ORG_CONTENTS = vim.trim([=[
#+TITLE: Test Org Contents
:PROPERTIES:
:ID: 1234
:OTHER: hello
:END:

:LOGBOOK:
:FIX: TEST
:END:

* Heading 1 that is a node
  :PROPERTIES:
  :ID: 5678
  :OTHER: world
  :END:

  Some content for the first heading.

* Heading 2 that is not a node

  Some content for the second heading.

  [[id:1234][Link to file node]] is here.
  [[id:5678][Link to heading node]] is here.
  [[https://example.com]] is a link without a description.
]=])

describe("Parser", function()
  local Parser = require("org-roam.parser")

  it("should parse an org file correctly", function()
    local output = Parser.parse(TEST_ORG_CONTENTS)

    -- Check our top-level property drawer
    assert.is_nil(output.drawers[1].heading)
    assert.equals(2, #output.drawers[1].properties)

    -- Check the position of the first key (all should be zero-based)
    assert.equals("ID", output.drawers[1].properties[1].key.text)
    assert.equals(2, output.drawers[1].properties[1].key.range.start.row)
    assert.equals(1, output.drawers[1].properties[1].key.range.start.column)
    assert.equals(40, output.drawers[1].properties[1].key.range.start.offset)
    assert.equals(2, output.drawers[1].properties[1].key.range.end_.row)
    assert.equals(3, output.drawers[1].properties[1].key.range.end_.col)
    assert.equals(41, output.drawers[1].properties[1].key.range.end_.offset)

    -- Check the position of the first value (all should be zero-based)
    assert.equals("1234", output.drawers[1].properties[1].value.text)
    assert.equals(2, output.drawers[1].properties[1].value.range.start.row)
    assert.equals(5, output.drawers[1].properties[1].value.range.start.column)
    assert.equals(45, output.drawers[1].properties[1].value.range.start.offset)

    -- Check the position of the second key (all should be zero-based)
    assert.equals("OTHER", output.drawers[1].properties[2].key.text)
    assert.equals(3, output.drawers[1].properties[2].key.range.start.row)
    assert.equals(0, output.drawers[1].properties[2].key.range.start.column)
    assert.equals(50, output.drawers[1].properties[2].key.range.start.offset)

    -- Check the position of the second value (all should be zero-based)
    assert.equals("hello", output.drawers[1].properties[2].value.text)
    assert.equals(3, output.drawers[1].properties[2].value.range.start.row)
    assert.equals(8, output.drawers[1].properties[2].value.range.start.column)
    assert.equals(58, output.drawers[1].properties[2].value.range.start.offset)

    -- TODO: Lines 12 & 13 for next property
    -- 144 offset for ID, 148 for value
    -- 156 offset for OTHER, 163 for value

    -- TODO: Lines 22 - 24 for links
    -- 291 for first link
    -- 333 for second link
    -- 378 for third link
  end)
end)