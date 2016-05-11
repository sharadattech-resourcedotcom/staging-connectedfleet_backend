class CreateCompanyEmails < ActiveRecord::Migration
  def change
    create_table :company_emails do |t|
    	t.belongs_to :company
    	t.column :email_type, :string
    	t.column :recipients, :string
    	t.column :subject, :string
    	t.column :content, :text
    end
  end
end
