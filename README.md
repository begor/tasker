# Tasker

Simple job scheduling/processing service.

A job is a collection of tasks, where each task has a name and a shell command. 
Tasks may depend on other tasks and require that those are executed beforehand. The service takes care of sorting the tasks to create a proper execution order.

## Up & Running

  * Install dependencies with `make install`
  * (optionally) Run tests with `make tests`
  * Start Phoenix endpoint with `make server`

Now you can use API on `localhost:4000`.

## API

API consists of two endpoints:

### /api/sort

Accepts job and sorts tasks, outputting them as a JSON. 
Example:

```
$ cat examples/many.json | http POST localhost:4000/api/sort
HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 219
content-type: application/json; charset=utf-8
date: Sun, 12 May 2019 20:21:33 GMT
server: Cowboy
x-request-id: FZ4JEgaGyxWGTDUAAAJB

[
    {
        "command": "touch 42",
        "name": "task-4"
    },
    {
        "command": "echo 'Hello!' > 42",
        "name": "task-2"
    },
    {
        "command": "cat 42 && echo 'Bye!' > 42",
        "name": "task-3"
    },
    {
        "command": "cat 42",
        "name": "task-1"
    },
    {
        "command": "rm 42",
        "name": "task-5"
    }
]
```


### /api/bash

Accepts job and sorts tasks, outputting them as bash script. 
Example:

```
$ cat examples/many.json | http POST localhost:4000/api/bash
HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 87
content-type: text/plain; charset=utf-8
date: Sun, 12 May 2019 20:22:37 GMT
server: Cowboy
x-request-id: FZ4JIL5X2zkf7bwAAAKB

#!/usr/bin/env bash
touch 42
echo 'Hello!' > 42
cat 42 && echo 'Bye!' > 42
cat 42
rm 42
```