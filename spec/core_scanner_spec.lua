describe("core.scanner", function()
    local join_path = require("org-roam.core.utils.io").join_path
    local Scanner = require("org-roam.core.scanner")

    local ORG_FILES_DIR = (function()
        local str = debug.getinfo(2, "S").source:sub(2)
        return join_path(vim.fs.dirname(str:match("(.*/)")), "files")
    end)()

    it("should support scanning a directory for org files", function()
        local error

        ---@type {[string]:org-roam.core.database.Node}
        local nodes = {}

        local scanner = Scanner
            :new({ ORG_FILES_DIR })
            :on_scan(function(scan)
                for _, node in ipairs(scan.nodes) do
                    if node then
                        -- We shouldn't have the same node twice
                        if nodes[node.id] then
                            error = "Already have node " .. node.id
                        end

                        nodes[node.id] = node
                    end
                end
            end)
            :on_error(function(err) error = err end)
            :start()

        vim.wait(1000, function() return not scanner:is_running() end)
        assert(not scanner:is_running(), "Scanner failed to complete in time")
        assert(not error, error)

        ---@type org-roam.core.database.Node
        local node

        node = assert(nodes["1"], "missing node 1")
        assert.equals("1", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("one", node.title)
        assert.same({ "1", "neo", "the one" }, node.aliases)
        assert.equals(0, node.level)
        assert.same({ "a", "b", "c" }, node.tags)
        assert.same({ "2", "3", "4" }, node.linked)

        node = assert(nodes["2"], "missing node 2")
        assert.equals("2", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("node two", node.title)
        assert.same({}, node.aliases)
        assert.equals(1, node.level)
        assert.same({ "a", "b", "c", "d", "e", "f" }, node.tags)
        assert.same({ "1", "3" }, node.linked)

        node = assert(nodes["3"], "missing node 3")
        assert.equals("3", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("node three", node.title)
        assert.same({}, node.aliases)
        assert.equals(2, node.level)
        assert.same({ "a", "b", "c", "d", "e", "f", "g", "h", "i" }, node.tags)
        assert.same({ "2" }, node.linked)

        node = assert(nodes["1234"], "missing node 1234")
        assert.equals("1234", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "test.org"), node.file)
        assert.equals("some title", node.title)
        assert.same({}, node.aliases)
        assert.equals(0, node.level)
        assert.same({ "a", "b", "c" }, node.tags)
        assert.same({ "1234", "5678" }, node.linked)

        node = assert(nodes["5678"], "missing node 5678")
        assert.equals("5678", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "test.org"), node.file)
        assert.equals("Heading 1 that is a node", node.title)
        assert.same({}, node.aliases)
        assert.equals(1, node.level)
        assert.same({ "a", "b", "c" }, node.tags)
        assert.same({}, node.linked)

        node = assert(nodes["9999"], "missing node 9999")
        assert.equals("9999", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "test.org"), node.file)
        assert.equals("Heading 3 that is a node with tags", node.title)
        assert.same({}, node.aliases)
        assert.equals(1, node.level)
        assert.same({ "a", "b", "c", "tag1", "tag2" }, node.tags)
        assert.same({}, node.linked)

        node = assert(nodes["links-1234"], "missing node links-1234")
        assert.equals("links-1234", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "links.org"), node.file)
        assert.equals("links", node.title)
        assert.same({}, node.aliases)
        assert.equals(0, node.level)
        assert.same({}, node.tags)
        assert.same({ "1234", "5678" }, node.linked)
    end)

    it("should support scanning explicitly-provided org files", function()
        local error

        ---@type {[string]:org-roam.core.database.Node}
        local nodes = {}

        local scanner = Scanner
            :new({ join_path(ORG_FILES_DIR, "one.org") })
            :on_scan(function(scan)
                for _, node in ipairs(scan.nodes) do
                    if node then
                        -- We shouldn't have the same node twice
                        if nodes[node.id] then
                            error = "Already have node " .. node.id
                        end

                        nodes[node.id] = node
                    end
                end
            end)
            :on_error(function(err) error = err end)
            :start()

        vim.wait(1000, function() return not scanner:is_running() end)
        assert(not scanner:is_running(), "Scanner failed to complete in time")
        assert(not error, error)

        ---@type org-roam.core.database.Node
        local node

        node = assert(nodes["1"], "missing node 1")
        assert.equals("1", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("one", node.title)
        assert.same({ "1", "neo", "the one" }, node.aliases)
        assert.equals(0, node.level)
        assert.same({ "a", "b", "c" }, node.tags)
        assert.same({ "2", "3", "4" }, node.linked)

        node = assert(nodes["2"], "missing node 2")
        assert.equals("2", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("node two", node.title)
        assert.same({}, node.aliases)
        assert.equals(1, node.level)
        assert.same({ "a", "b", "c", "d", "e", "f" }, node.tags)
        assert.same({ "1", "3" }, node.linked)

        node = assert(nodes["3"], "missing node 3")
        assert.equals("3", node.id)
        assert.equals(join_path(ORG_FILES_DIR, "one.org"), node.file)
        assert.equals("node three", node.title)
        assert.same({}, node.aliases)
        assert.equals(2, node.level)
        assert.same({ "a", "b", "c", "d", "e", "f", "g", "h", "i" }, node.tags)
        assert.same({ "2" }, node.linked)
    end)
end)