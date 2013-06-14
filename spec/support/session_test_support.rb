module SessionTestSupport
  def complete_deferred *tasks, wait_time: 3
    sleep wait_time
    tasks.each {|t| task_done t }
  end
end
