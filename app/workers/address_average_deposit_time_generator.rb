class AddressAverageDepositTimeGenerator
  include Sidekiq::Worker

  def perform(address_id)
    address = Address.find(address_id)
    address.update(average_deposit_time: average_deposit_time)
  end

  private

  def average_deposit_time
    interest_bearing_deposits = 0
    uninterest_bearing_deposits = 0
    milliseconds_in_day = BigDecimal(24 * 60 * 60 * 1000)
    ended_at =  time_in_milliseconds(Time.current)
    sum_interest_bearing = address.cell_outputs.nervos_dao_withdrawing.unconsumed_at(ended_at).reduce(0) do |memo, nervos_dao_withdrawing_cell|
      nervos_dao_withdrawing_cell_generated_tx = nervos_dao_withdrawing_cell.generated_by
      nervos_dao_deposit_cell = nervos_dao_withdrawing_cell_generated_tx.cell_inputs.order(:id)[nervos_dao_withdrawing_cell.cell_index].previous_cell_output
      interest_bearing_deposits += nervos_dao_deposit_cell.capacity
      memo + nervos_dao_deposit_cell.capacity * (nervos_dao_withdrawing_cell.block_timestamp - nervos_dao_deposit_cell.block_timestamp) / milliseconds_in_day
    end
    sum_uninterest_bearing = address.cell_outputs.nervos_dao_deposit.unconsumed_at(ended_at).reduce(0) do |memo, nervos_dao_deposit_cell|
      uninterest_bearing_deposits += nervos_dao_deposit_cell.capacity

      memo + nervos_dao_deposit_cell.capacity * (ended_at - nervos_dao_deposit_cell.block_timestamp) / milliseconds_in_day
    end

    (sum_interest_bearing + sum_uninterest_bearing) / (interest_bearing_deposits + uninterest_bearing_deposits)
  end

  def time_in_milliseconds(time)
    (time.to_f * 1000).floor
  end
end
