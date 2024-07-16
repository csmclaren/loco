function Inlines(inlines)
  local content = {}
  local i = 1

  while i <= #inlines do
    local inline = inlines[i]
    i = i + 1

    if not (inline.format == "html" and inline.t == "RawInline" and inline.text:match("<kbd>")) then
      table.insert(content, inline)
    else
      local inner_content = {}

      while i <= #inlines do
        inline = inlines[i]
        i = i + 1

        if not (inline.format == "html" and inline.t == "RawInline" and inline.text:match("</kbd>")) then
          table.insert(inner_content, inline)
        else
          break
        end
      end

      if FORMAT == "texinfo" then
        table.insert(content, pandoc.RawInline("texinfo", "@kbd{"))
        for _, item in ipairs(inner_content) do
          table.insert(content, item)
        end
        table.insert(content, pandoc.RawInline("texinfo", "}"))
      else
        table.insert(content, pandoc.RawInline("html", "<kbd>"))
        for _, item in ipairs(inner_content) do
          table.insert(content, item)
        end
        table.insert(content, pandoc.RawInline("html", "</kbd>"))
      end
    end
  end

  return content
end
