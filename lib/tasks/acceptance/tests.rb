namespace :acceptance do
  desc 'Run acceptance tests.'
  task :tests do
    unless acceptance_enabled
      puts 'Acceptance is not enabled.'
      exit(0)
    end

    unless validate_branch(/^release-/) || validate_branch(/^hotfix-/)
      puts 'Not a release or hotfix branch.'
      exit(0)
    end

    stdout = `bundle exec rake beaker:sets | xargs`
    sets = stdout.split(' ')
    node_total = ENV['CIRCLE_NODE_TOTAL'].to_i
    node_index = ENV['CIRCLE_NODE_INDEX'].to_i
    nodes = []
    l = sets.length - 1

    (0..l).each do |i|
      nodes << sets[i] if (i % node_total) == node_index
    end

    unless nodes.length
      puts 'No nodes configured for this node.'
      exit(0)
    end

    test_nodes(nodes)
  end
end
