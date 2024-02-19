return {
  'pwntester/octo.nvim',
  dependencies ={
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = {
    use_local_fs = false,                    -- use local files on right side of reviews
    enable_builtin = false,                  -- shows a list of builtin actions when no action is provided
    default_remote = {"upstream", "origin"}; -- order to try remotes
    ssh_aliases = {},                        -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`
    reaction_viewer_hint_icon = "";         -- marker for user reactions
    user_icon = " ";                        -- user icon
    timeline_marker = "";                   -- timeline marker
    timeline_indent = "2";                   -- timeline indentation
    right_bubble_delimiter = "";            -- bubble delimiter
    left_bubble_delimiter = "";             -- bubble delimiter
    github_hostname = "";                    -- GitHub Enterprise host
    snippet_context_lines = 4;               -- number or lines around commented lines
    gh_env = {},                             -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
    timeout = 5000,                          -- timeout for requests between the remote server
    ui = {
      use_signcolumn = true,                 -- show "modified" marks on the sign column
    },
    issues = {
      order_by = {                           -- criteria to sort results of `Octo issue list`
        field = "UPDATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
        direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
      }
    },
    pull_requests = {
      order_by = {                           -- criteria to sort the results of `Octo pr list`
        field = "UPDATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
        direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
      },
      always_select_remote_on_create = false -- always give prompt to select base remote repo when creating PRs
    },
    file_panel = {
      size = 10,                             -- changed files panel rows
      use_icons = true                       -- use web-devicons in file panel (if false, nvim-web-devicons does not need to be installed)
    },
    mappings = {
      issue = {
        close_issue = { lhs = "<leader>oc", desc = "close issue" },
        reopen_issue = { lhs = "<leader>oo", desc = "reopen issue" },
        list_issues = { lhs = "<leader>ol", desc = "list open issues on same repo" },
        reload = { lhs = "<C-r>", desc = "reload issue" },
        --open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
        copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
        add_assignee = { lhs = "<leader>oaa", desc = "add assignee" },
        remove_assignee = { lhs = "<leader>oad", desc = "remove assignee" },
        create_label = { lhs = "<leader>olc", desc = "create label" },
        add_label = { lhs = "<leader>ola", desc = "add label" },
        remove_label = { lhs = "<leader>old", desc = "remove label" },
        --goto_issue = { lhs = "<leader>ogi", desc = "navigate to a local repo issue" },
        add_comment = { lhs = "<leader>oca", desc = "add comment" },
        delete_comment = { lhs = "<leader>ocd", desc = "delete comment" },
        next_comment = { lhs = "]c", desc = "go to next comment" },
        prev_comment = { lhs = "[c", desc = "go to previous comment" },
        react_hooray = { lhs = "<leader>orp", desc = "add/remove 🎉 reaction" },
        react_heart = { lhs = "<leader>orh", desc = "add/remove ❤️ reaction" },
        react_eyes = { lhs = "<leader>ore", desc = "add/remove 👀 reaction" },
        react_thumbs_up = { lhs = "<leader>or+", desc = "add/remove 👍 reaction" },
        react_thumbs_down = { lhs = "<leader>or-", desc = "add/remove 👎 reaction" },
        react_rocket = { lhs = "<leader>orr", desc = "add/remove 🚀 reaction" },
        react_laugh = { lhs = "<leader>orl", desc = "add/remove 😄 reaction" },
        react_confused = { lhs = "<leader>orc", desc = "add/remove 😕 reaction" },
      },
      pull_request = {
        checkout_pr = { lhs = "<leader>oo", desc = "checkout PR" },
        -- merge_pr = { lhs = "<leader>opm", desc = "merge commit PR" },
        squash_and_merge_pr = { lhs = "<leader>om", desc = "squash and merge PR" },
        list_commits = { lhs = "<leader>oc", desc = "list PR commits" },
        list_changed_files = { lhs = "<leader>of", desc = "list PR changed files" },
        show_pr_diff = { lhs = "<leader>od", desc = "show PR diff" },
        --add_reviewer = { lhs = "<leader>ova", desc = "add reviewer" },
        --remove_reviewer = { lhs = "<leader>ovd", desc = "remove reviewer request" },
        close_issue = { lhs = "<leader>oc", desc = "close PR" },
        reopen_issue = { lhs = "<leader>oo", desc = "reopen PR" },
        list_issues = { lhs = "<leader>ol", desc = "list open issues on same repo" },
        reload = { lhs = "<C-r>", desc = "reload PR" },
        --open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
        copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
        goto_file = { lhs = "gf", desc = "go to file" },
        add_assignee = { lhs = "<leader>oaa", desc = "add assignee" },
        remove_assignee = { lhs = "<leader>oad", desc = "remove assignee" },
        create_label = { lhs = "<leader>olc", desc = "create label" },
        add_label = { lhs = "<leader>ola", desc = "add label" },
        remove_label = { lhs = "<leader>old", desc = "remove label" },
        -- goto_issue = { lhs = "<leader>ogi", desc = "navigate to a local repo issue" },
        add_comment = { lhs = "<leader>oca", desc = "add comment" },
        delete_comment = { lhs = "<leader>ocd", desc = "delete comment" },
        next_comment = { lhs = "]c", desc = "go to next comment" },
        prev_comment = { lhs = "[c", desc = "go to previous comment" },
        react_hooray = { lhs = "<leader>orp", desc = "add/remove 🎉 reaction" },
        react_heart = { lhs = "<leader>orh", desc = "add/remove ❤️ reaction" },
        react_eyes = { lhs = "<leader>ore", desc = "add/remove 👀 reaction" },
        react_thumbs_up = { lhs = "<leader>or+", desc = "add/remove 👍 reaction" },
        react_thumbs_down = { lhs = "<leader>or-", desc = "add/remove 👎 reaction" },
        react_rocket = { lhs = "<leader>orr", desc = "add/remove 🚀 reaction" },
        react_laugh = { lhs = "<leader>orl", desc = "add/remove 😄 reaction" },
        react_confused = { lhs = "<leader>orc", desc = "add/remove 😕 reaction" },
      },
      review_thread = {
        -- goto_issue = { lhs = "<leader>ogi", desc = "navigate to a local repo issue" },
        add_comment = { lhs = "<leader>oca", desc = "add comment" },
        add_suggestion = { lhs = "<leader>osa", desc = "add suggestion" },
        delete_comment = { lhs = "<leader>ocd", desc = "delete comment" },
        next_comment = { lhs = "]c", desc = "go to next comment" },
        prev_comment = { lhs = "[c", desc = "go to previous comment" },
        select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
        select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
        close_review_tab = { lhs = "<leader>oq", desc = "close review tab" },
        react_hooray = { lhs = "<leader>orp", desc = "add/remove 🎉 reaction" },
        react_heart = { lhs = "<leader>orh", desc = "add/remove ❤️ reaction" },
        react_eyes = { lhs = "<leader>ore", desc = "add/remove 👀 reaction" },
        react_thumbs_up = { lhs = "<leader>or+", desc = "add/remove 👍 reaction" },
        react_thumbs_down = { lhs = "<leader>or-", desc = "add/remove 👎 reaction" },
        react_rocket = { lhs = "<leader>orr", desc = "add/remove 🚀 reaction" },
        react_laugh = { lhs = "<leader>orl", desc = "add/remove 😄 reaction" },
        react_confused = { lhs = "<leader>orc", desc = "add/remove 😕 reaction" },
      },
      submit_win = {
        approve_review = { lhs = "<leader>oa", desc = "approve review" },
        comment_review = { lhs = "<leader>oc", desc = "comment review" },
        request_changes = { lhs = "<leader>or", desc = "request changes review" },
        close_review_tab = { lhs = "<leader>oq", desc = "close review tab" },
      },
      review_diff = {
        add_review_comment = { lhs = "<leader>oc", desc = "add a new review comment" },
        add_review_suggestion = { lhs = "<leader>os", desc = "add a new review suggestion" },
        focus_files = { lhs = "<leader>oe", desc = "move focus to changed file panel" },
        toggle_files = { lhs = "<leader>ob", desc = "hide/show changed files panel" },
        next_thread = { lhs = "]t", desc = "move to next thread" },
        prev_thread = { lhs = "[t", desc = "move to previous thread" },
        select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
        select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
        close_review_tab = { lhs = "<leader>oq", desc = "close review tab" },
        toggle_viewed = { lhs = "<leader>ov", desc = "toggle viewer viewed state" },
        goto_file = { lhs = "gf", desc = "go to file" },
      },
      file_panel = {
        next_entry = { lhs = "j", desc = "move to next changed file" },
        prev_entry = { lhs = "k", desc = "move to previous changed file" },
        select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
        refresh_files = { lhs = "R", desc = "refresh changed files panel" },
        focus_files = { lhs = "<leader>oe", desc = "move focus to changed file panel" },
        toggle_files = { lhs = "<leader>ob", desc = "hide/show changed files panel" },
        select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
        select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
        close_review_tab = { lhs = "<leader>oq", desc = "close review tab" },
        toggle_viewed = { lhs = "<leader>ov", desc = "toggle viewer viewed state" },
      }
    }
  }
}
