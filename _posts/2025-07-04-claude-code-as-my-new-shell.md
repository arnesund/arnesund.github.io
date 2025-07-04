---
layout: post
title: "Claude Code as My Default Shell"
date: "2025-07-04"
categories:
  - "AI"
tags:
  - "claude"
  - "shell"
  - "productivity"
  - "cli"
---

# Claude Code as My Default Shell

As a longtime Linux user who lives in the shell, I've always relied on carefully crafted aliases and scripts to move fast through my daily work. I do everything from the command line - coding, data analysis, server admin, API calls, ad-hoc automation. The terminal has been my preferred interface ever since installing Slackware back in the 90s.

But today marks an exciting milestone: Claude Code has become my new default shell.

I've been impressed by Claude Code's capabilities from day one. It makes complex tasks both easier and faster to do. The power of Claude models has made seemingly gnarly tasks suddenly both possible and easy.

Now, instead of manually typing out commands, I can simply ask Claude Code to:

- Perform data analysis on CSVs in my Downloads folder  
- Fetch data from remote systems using APIs
- Handle complex git operations and code refactorings
- Transform data in ways that would usually require long pipes with jq and xargs and what have you

The speed difference is astonishing. I used to check the man pages regularly or do `--help` to figure out the syntax. It was hard to remember all the options. The last couple years I turned to LLMs for those details, using Simon Willison's excellent [LLM CLI tool](https://llm.datasette.io/) and copy-pasting the results to the shell. However, Claude Code will happily construct long command lines AND run them, and it's fast. It comes up with combinations of commands I had never thought of too.

I run `claude --dangerously-skip-permissions` as my default mode. After working with it extensively, I trust it. The moment I open a new iTerm2 window, I'm instantly in Claude Code in my home folder. No dev containers, no sandbox, full access only. Let's see what kind of mishaps will happen but I'm not particularly worried.

The fundamental shift LLMs have brought to terminal users like me is that we're moving from memorizing commands to describing intent. The shell remains as powerful as ever, but now it understands what we're trying to accomplish, not just what we're literally typing.

If you got inspired, here's the very simple Fish shell snippet needed to get Claude as your shell:
```
$ cat >> ~/.config/fish/config.fish <<EOF
  # Everything inside this block is executed for every interactive fish
  if status is-interactive
      claude --dangerously-skip-permissions
  end
EOF
```
