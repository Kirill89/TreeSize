defmodule TreeSize.CLI do
  def size_to_string(size) do
    cond do
      size > 1024 * 1024 * 1024 -> "#{Float.round(size / (1024 * 1024 * 1024), 1)} G"
      size > 1024 * 1024 -> "#{Float.round(size / (1024 * 1024), 1)} M"
      size > 1024 -> "#{Float.round(size / 1024, 1)} K"
      true -> "#{size} B"
    end
  end

  def print(treeItem) do
    # TODO: use https://github.com/djm/table_rex
    IO.puts "-2 to exit"
    IO.puts "-1 to go up"
    elem(treeItem, 3)
    |> Stream.with_index
    |> Enum.each(
         fn ({item, index}) ->
           IO.puts "#{index} \t #{elem(item, 0)} \t|\t #{elem(item, 2)} \t|\t #{size_to_string(elem(item, 1))}"
         end
       )
  end

  def menu(tree, history_stack) do
    print(tree)
    {index, _} = IO.gets("Select item: ")
                 |> Integer.parse

    cond do
      index === -1 and length(history_stack) > 0 ->
        [h | t] = history_stack
        menu(h, t)
      index >= 0 ->
        sub_items = elem(tree, 3)

        if length(sub_items) > index do
          if elem(Enum.at(sub_items, index), 2) === :folder do
            menu(Enum.at(elem(tree, 3), index), [tree] ++ history_stack)
          else
            IO.puts("not folder")
            menu(tree, history_stack)
          end
        else
          IO.puts("out of index")
          menu(tree, history_stack)
        end
      true -> IO.puts("bye")
    end
  end

  def main(args \\ []) do
    {opts, _, _} = OptionParser.parse(
      args,
      witches: [
        path: :string
      ],
      aliases: [
        p: :path
      ]
    )

    tree = TreeSize.traverse(opts[:path])
    menu(tree, [])
  end
end
