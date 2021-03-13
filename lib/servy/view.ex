defmodule Servy.View do
  @templates_path Path.expand("templates", File.cwd!)

  def render(conv, function, bindings \\ [])

  # Not performant way to render, because takes the file from the disk,
  # parse it, and evaluate it every time the function is called.
  def render(conv, template, bindings) when is_binary(template) do
    content = 
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, resp_body: content }
  end

  def render(conv, function, bindings) do
    %{ conv | status: 200, resp_body: apply(function, [bindings]) }
  end
end
