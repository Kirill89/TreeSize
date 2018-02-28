defmodule TreeSize do
  def traverse(path) do
    if File.dir?(path) do
      {status, results} = File.ls(path)

      if status === :ok do
        sub_items = results
                    |> Enum.map(fn name -> Task.async(fn -> traverse(Path.join(path, name)) end) end)
                    |> Enum.map(fn task -> Task.await(task, :infinity) end)
                    |> Enum.filter(fn (data) -> data !== nil end)
                    |> Enum.sort(fn (a, b) -> elem(a, 1) >= elem(b, 1) end)

        folder_size = Enum.reduce(
          sub_items,
          0,
          fn
            ({_, size, _, _}, acc) -> size + acc
            ({_, size, _}, acc) -> size + acc
          end
        )

        {path, folder_size, :folder, sub_items}
      else
        nil
      end
    else
      {status, result} = File.stat(path)
      if status === :ok do
        {path, result.size, :file}
      else
        nil
      end
    end
  end
end
