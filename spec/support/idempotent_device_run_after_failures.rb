shared_examples 'an idempotent device run after failures' do |allowed_fail_runs|   
  it "can fail for new resources" do 
    allowed_fail_runs.times do |run|
      @result = run_puppet_device_on(agents)      
      expect([0, 1, 2]).to include(@result.exit_code)
  
      break unless @result.exit_code == 1
    end
  end

  # Only run if loop was not broken...
  it 'can make changes on the second run' do
    @result = run_puppet_device_on(agents)
    expect([0, 2]).to include(@result.exit_code)
  end

  it 'should be idempotent on the third run' do
    @result = run_puppet_device_on(agents)
    expect(@result.exit_code).to eq(0)    
  end
end
