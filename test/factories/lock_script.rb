FactoryBot.define do
  factory :lock_script do
    address
    hash_type { "type" }
    args { "0x#{SecureRandom.hex(20)}" }
    code_hash { "0x#{SecureRandom.hex(32)}" }
  end
end
