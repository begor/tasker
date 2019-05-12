defmodule TaskerWeb.TaskControllerTest do
  use TaskerWeb.ConnCase

  test "400 on bad requires", %{conn: conn} do
    task = %{"name" => "test1", "requires" => ["test2"], "command" => "true"}

    request = %{"tasks" => [task]}

    response = conn
    |> post("/api/sort", request)
    |> json_response(400)

    assert response == %{"error" => "Invalid requires in task test1"}
  end

  test "400 on self-requires", %{conn: conn} do
    task = %{"name" => "test1", "requires" => ["test1"], "command" => "true"}

    request = %{"tasks" => [task]}

    response = conn
    |> post("/api/sort", request)
    |> json_response(400)

    assert response == %{"error" => "Invalid requires in task test1"}
  end

  test "400 on cycle", %{conn: conn} do
    task1 = %{"name" => "test1", "requires" => ["test2"], "command" => "true"}
    task2 = %{"name" => "test2", "requires" => ["test1"], "command" => "true"}

    request = %{"tasks" => [task1, task2]}

    response = conn
    |> post("/api/sort", request)
    |> json_response(400)

    assert response == %{"error" => "Detected cycle in test2 requires"}
  end

  test "sort valid tasks", %{conn: conn} do
    task1 = %{"name" => "test1", "requires" => ["test4", "test3"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2"], "command" => "true"}
    task4 = %{"name" => "test4", "command" => "true"}

    request = %{"tasks" => [task4, task3, task1, task2]}

    expected_order = [task4, task2, task3, task1]
    expected_response = Enum.map(expected_order, &Map.delete(&1, "requires"))

    response = conn
    |> post("/api/sort", request)
    |> json_response(200)

    assert response == expected_response
  end

  test "bash format valid tasks", %{conn: conn} do
    task1 = %{"name" => "test1", "requires" => ["test4", "test3"], "command" => "true"}
    task2 = %{"name" => "test2", "command" => "true"}
    task3 = %{"name" => "test3", "requires" => ["test2"], "command" => "true"}
    task4 = %{"name" => "test4", "command" => "true"}

    request = %{"tasks" => [task4, task3, task1, task2]}

    expected_order = [task4, task2, task3, task1]
    expected_response = "#!/usr/bin/env bash\n#{expected_order |> Enum.map(&Map.get(&1, "command")) |> Enum.join("\n")}"

    response = conn
    |> post("/api/bash", request)
    |> text_response(200)

    assert response == expected_response
  end
end