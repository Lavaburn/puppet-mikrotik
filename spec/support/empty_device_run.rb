shared_examples 'an empty device run' do  
  it 'should not make changes the first time' do
    @result = run_puppet_device_on(agents)
    expect(@result.exit_code).to eq(0)
  end
end
