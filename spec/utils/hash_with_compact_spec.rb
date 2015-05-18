require 'spec_helper'
require 'utils/hash_with_compact'

RSpec.describe Hash do
  describe '#compact' do
    it 'removes nil entries at the top level of the hash' do
      hash = {:key1 => "value", :key2 => nil, :key3 => ""}
      hash = hash.compact
      
      expect(hash).to have_key(:key1)
      expect(hash).to have_key(:key3)
      expect(hash).not_to have_key(:key2)
    end
    
    it 'removes nil entries in nested hashes' do
      hash = {:key1 => "value", :key2 => nil, :key3 => {:subkey1 => "value2",
          :subkey2 => nil}}
      compacted = hash.compact
      
      expect(compacted).to have_key(:key3)
      expect(compacted[:key3]).to have_key(:subkey1)
      expect(compacted[:key3]).not_to have_key(:subkey2)
    end
    
    it 'removes a nested hash if all keys are nil' do
      hash = {:key1 => "value", :key2 => nil, :key3 => {:subkey1 => "value2",
        :subkey2 => nil}, :key4 => {:subkey1 => nil, :subkey2 => nil}}
      compacted = hash.compact
      expect(compacted).not_to have_key(:key4)
    end
  end
end