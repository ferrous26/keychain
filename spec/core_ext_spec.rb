describe NSMutableString, '#camelize!' do
  it 'should take a snake case string and make it camel case' do
    'a_method_name'.camelize!.should == 'AMethodName'
    'method_name'.camelize!.should == 'MethodName'
    'name'.camelize!.should == 'Name'
  end
  it 'should take a camel case string and do nothing to it' do
    'AMethodName'.camelize!.should == 'AMethodName'
    'MethodName'.camelize!.should == 'MethodName'
    'Name'.camelize!.should == 'Name'
  end
  it 'should return self' do
    string = 'TestString'
    string.camelize!.should be string
  end
  it 'returns nil for an empty string' do
    ''.camelize!.should be_nil
  end
end
