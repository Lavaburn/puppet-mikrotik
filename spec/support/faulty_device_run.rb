shared_examples 'a faulty device run' do  
  it 'should raise an error' do
    @result = run_puppet_device_on(agents)
    expect([1, 6]).to include(@result.exit_code)
  end
end
