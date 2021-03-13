defmodule Servy.Plugins do

  alias Servy.Conv

  def emojify(%Conv{status: 200} = conv) do
    body = "🎉" <> "\n\n" <> conv.resp_body <> "\n\n" <> "🎉"
  
    %{ conv | resp_body: body }
  end

  def emojify(%Conv{} = conv), do: conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      IO.puts "#{path} not found."
    end
    
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do 
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end
  
  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end

    conv
  end
end
