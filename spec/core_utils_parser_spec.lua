describe("utils.parser", function()
    local parser = require("org-roam.core.utils.parser")

    describe("parse_property_value", function()
        it("should parse unquoted values delimited by whitespace", function()
            local value = "one two three"
            assert.same({ "one", "two", "three" }, parser.parse_property_value(value))
        end)

        it("should group quoted values together", function()
            local value = "a \"b c\" d"
            assert.same({ "a", "b c", "d" }, parser.parse_property_value(value))
        end)

        it("should support the entire value being quoted", function()
            local value = "\"a b c\""
            assert.same({ "a b c" }, parser.parse_property_value(value))
        end)
    end)
end)
