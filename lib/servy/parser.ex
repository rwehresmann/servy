defmodule Servy.Parser do

  alias Servy.Conv #, as: Conv

  def parse(request) do
    [head | tail] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(head, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params_string = List.first(tail)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

#  def parse_headers([head | tail], headers) do
#    [key, value] = String.split(head, ": ")
#
#    headers = Map.put(headers, key, value)
#
#    parse_headers(tail, headers)
#  end
#
# def parse_headers([], headers), do: headers 

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn(line, headers) -> 
      [key, value] = String.split(line, ": ")
      Map.put(headers, key, value)
    end)
  end

  @doc """
    Parses the given param string of the form `key1=value1&key2=value2`
    into a map with corresponding keys and values.

    ## Examples:
        iex> params_string = "name=Zé Colmeia&type=Cartoon"
        iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
        %{"name" => "Zé Colmeia", "type" => "Cartoon"}
        iex> Servy.Parser.parse_params("multipart/form-data", params_string)
        %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params("application/json", params_string) do
    Poison.Parser.parse!(params_string, %{})
  end

  def parse_params(_, _), do: %{}
end
