defmodule Tasker.SortTest do
  use ExUnit.Case, async: true

  defp correct_order(tasks, expected_order) do
    Tasker.Operations.sort(tasks) == Enum.map(expected_order, &Map.delete(&1, "requires"))
  end

  test "no tasks" do
    assert correct_order([], [])
  end

  test "task without requires" do
    task = %{"name" => "task-1", "command" => "true"}
    
    assert correct_order([task], [task])
  end

  test "task with empty requires" do
    task = %{"name" => "task-1", "command" => "true", "requires" => []}
    
    assert correct_order([task], [task])
  end

  test "two tasks without requires" do
    task1 = %{"name" => "test1", "requires" => [], "command" => "true"}
    task2 = %{"name" => "test2", "requires" => [], "command" => "true"}
    
    assert correct_order([task1, task2], [task1, task2]) || correct_order([task1, task2], [task2, task1])
  end

  test "two tasks with requires" do
    task1 = %{"name" => "test1", "requires" => ["test2"], "command" => "true"}
    task2 = %{"name" => "test2", "requires" => [], "command" => "true"}

    assert correct_order([task1, task2], [task2, task1]) 
  end

  test "three tasks with requires" do
    task1 = %{"name" => "test1", "requires" => ["test3"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2"], "command" => "true"}

    assert correct_order([task1, task2, task3], [task2, task3, task1])   
  end

  test "three tasks with multiple requires" do
    task1 = %{"name" => "test1", "requires" => ["test3", "test2"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2"], "command" => "true"}

    assert correct_order([task1, task2, task3], [task2, task3, task1])
  end

  test "fout tasks with multi-level requires" do
    task1 = %{"name" => "test1", "requires" => ["test4", "test3"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2"], "command" => "true"}
    task4 = %{"name" => "test4", "command" => "true"}

    assert correct_order([task1, task2, task3, task4], [task4, task2, task3, task1])  
  end

  test "two tasks with cycle" do
    task1 = %{"name" => "test1", "requires" => ["test2"], "command" => "true"}
    task2 = %{"name" => "test2", "requires" => ["test1"], "command" => "true"}

    assert Tasker.Operations.sort([task1, task2]) == {:error, "Detected cycle in tasks requires"}
  end

  test "four tasks with cycle" do
    task1 = %{"name" => "test1", "requires" => ["test4", "test3"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2", "test1"], "command" => "true"}  # Cycle test1->test3>test1
    task4 = %{"name" => "test4", "command" => "true"}

    assert Tasker.Operations.sort([task1, task2, task3, task4]) == {:error, "Detected cycle in tasks requires"}
  end
end
