require 'rails_helper'

RSpec.describe DataIndex do
  subject do
    Class.new do
      DATA = [
        {
          "Name" => "A+",
          "Type" => "Array",
          "Designed by" => "Arthur Whitney"
        },
        {
          "Name" => "ActionScript",
          "Type" => "Compiled", # Cut data to keep tests smaller
          "Designed by" => "Gary Grossman"
        },
        {
          "Name" => "Ada",
          "Type" => "Compiled, Imperative",# Cut data to keep tests smaller
          "Designed by" => "Tucker Taft, Jean Ichbiah"
        }
      ]

      extend DataIndex
    end
  end

  it 'should provide .name_index' do
    expect(subject.name_index).to eq({
      'A+' => [{
        "Name" => "A+",
        "Type" => "Array",
        "Designed by" => "Arthur Whitney"
      }],
      'ActionScript' => [{
        "Name" => "ActionScript",
        "Type" => "Compiled",
        "Designed by" => "Gary Grossman"
      }],
      'Ada' => [{
        "Name" => "Ada",
        "Type" => "Compiled, Imperative",
        "Designed by" => "Tucker Taft, Jean Ichbiah"
      }]
    })
  end

  it 'should provide .type_index' do
    expect(subject.type_index).to eq({
      'Array' => [
        {
        "Name" => "A+",
        "Type" => "Array",
        "Designed by" => "Arthur Whitney"
        }
      ],
      'Compiled' => [
        {
          "Name" => "ActionScript",
          "Type" => "Compiled",
          "Designed by" => "Gary Grossman"
        },
        {
          "Name" => "Ada",
          "Type" => "Compiled, Imperative",
          "Designed by" => "Tucker Taft, Jean Ichbiah"
        }
      ],
      'Imperative' => [
        {
          "Name" => "Ada",
          "Type" => "Compiled, Imperative",
          "Designed by" => "Tucker Taft, Jean Ichbiah"
        }
      ]
    })
  end

  it 'should provide .designers_index' do
    expect(subject.designers_index).to eq({
      'Arthur Whitney' => [
        {
        "Name" => "A+",
        "Type" => "Array",
        "Designed by" => "Arthur Whitney"
        }
      ],
      'Gary Grossman' => [
        {
          "Name" => "ActionScript",
          "Type" => "Compiled",
          "Designed by" => "Gary Grossman"
        }
      ],
      'Tucker Taft' => [
        {
          "Name" => "Ada",
          "Type" => "Compiled, Imperative",
          "Designed by" => "Tucker Taft, Jean Ichbiah"
        }
      ],
      'Jean Ichbiah' => [
        {
          "Name" => "Ada",
          "Type" => "Compiled, Imperative",
          "Designed by" => "Tucker Taft, Jean Ichbiah"
        }
      ]
    })
  end

  context '#make_array' do
    it 'should convert comma separated string into array' do
      expect(subject.make_array 'a, b, c').to eq ['a', 'b', 'c']
    end
  end
end
