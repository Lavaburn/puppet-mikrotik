shared_examples 'an idempotent device run' do  
  it 'should make changes the first time' do
    @result = run_puppet_device_on(agents)
    expect(@result.exit_code).to eq(2)
  end

  it 'should be idempotent on the second run' do
    @result = run_puppet_device_on(agents)
    expect(@result.exit_code).to eq(0)    
  end
end
