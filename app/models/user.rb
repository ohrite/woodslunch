class User < ActiveRecord::Base

  include RoleModel
  roles :admin

  belongs_to :account
  has_many :orders

  validates :email, :presence => true,
      :uniqueness => { :case_sensitive => false }
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :account_id, :presence => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable,
  # :registerable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
      :first_name, :last_name, :account_id, :preferred_grade

  def name
    "#{first_name} #{last_name}"
  end

  def students
    self.account.students
  end

  def grade
    preferred_grade
  end
end
