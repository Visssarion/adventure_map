function print_event_queue(queue)
    queue = queue or G.E_MANAGER.queues.base
    for index, event in ipairs(queue) do
        print(index)
        print(inspectFunction(event.func))
        print(event)
    end
end