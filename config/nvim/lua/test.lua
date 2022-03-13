local path = "/home/cseickel/repos/"
local utils = require("neo-tree.utils")
local index = utils.split_path(path)[1]
local other, _ = utils.split_path(path)

print("index: " .. tostring(index))
print("other: " .. tostring(other))
