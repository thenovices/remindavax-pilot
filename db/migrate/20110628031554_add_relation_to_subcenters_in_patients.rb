class AddRelationToSubcentersInPatients < ActiveRecord::Migration
  def self.up
    add_column :patients, :subcenter_id, :integer
    remove_column :patients, :encrypted_subcenter
  end

  def self.down
    remove_column :patients, :subcenter_id
    add_column :patients, :encrypted_subcenter, :string
  end
end
