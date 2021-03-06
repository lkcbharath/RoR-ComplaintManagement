# RoR-ComplaintManagement

- After cloning, to run the application, type the following in a terminal opened at the root of it:

    ```
    bundle install
    rake db:create
    rake db:migrate
    rails s
    ```

	and you will be able to see the application in action.

## Objectives:

The objectives of this project are:

1. User authentication with 1 admin user.

2. Accept complaints from all users.

3. Allow admin (with special privileges) to update the status of complaint from pending, to processing and complete.

4. The person who created the complaint should be finally able to close the complaint after resolution.

5. Make 2 different dashboards for normal users and resolving authorities.

6. Now add validations to check if complaint title is not empty. As told it should do frontend as well as model validation.

7. Also modify the authentication to ask for name also while creating a account. You will have to add column in database and modify the controllers of devise also.

## Creating the application:

- Create the application with the name ComplaintManagement using the MySQL database with the command:

	`rails create new ComplaintManagement -d mysql`

- Navigate to the folder and then generate a scaffold to generate the MVC for a resource with name as Complaint, and three fields being the Name, Title and Details using:

	`rails g scaffold Complaint name:string title:string details:text`

- Change the default route of the application in `config/routes.rb`: 

	```ruby
	root "complaints#index"
	```

- For authentication, add the gem 'devise' to the `Gemfile`.

- Each time a gem is added, remember to execute

	`bundle install`

- Install all necessary components needed for devise by:

	`rails generate devise:install`

- Using devise, the resource and corresponding MVC for the user are first created by the command:

	`rails generate devise User`
	
- IMPORTANT: In newer versions of devise, it abstracts some functionality of ORM. To fix it, allow the User model (`app/models/user.rb`) to extend the Models Class from Devise:

	```ruby
	class User < ApplicationRecord extend Devise::Models
	```
	
- Finally, perform the migrations, then generate views for the User resource:
	
	```
	rake db:migrate
	rails generate devise:views
	```
- Using devise, the model & views for the user are created by:

- To authenticate users on opening any page of the application, add this filter to the Complaints controller (`controllers/complaint_controllers.rb`)

	```ruby
	before_action :authenticate_user!
	```

- Add the gems 'bootstrap-sass' & 'jquery-rails' to the `Gemfile` to generate a list of routes for easier modification.

- Modify the main HTML page, i.e. `app/layouts/application.html.erb` to display options for logging in and out, and account details:

	```html+erb
	<!--...-->
	<body>
	  <header class="navbar navbar-fixed-top navbar-inverse">
	    <div class="container">
          <nav>
            <ul class="nav navbar-nav navbar-right">
	      <li><%= link_to "Home",   root_path , class: "btn "%></li>
	          <% if user_signed_in? %>
	            <li><%= link_to "Account", edit_user_registration_path, class: "btn "  %></li>
	            <li>
	              <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
	            </li>
	          <% else %>
	            <li><%= link_to "Sign Up", new_user_registration_path, class: "btn " %></li>
	            <li><%= link_to "Sign In", new_user_session_path, class: "btn " %></li>
	          <% end %>
	        </ul>
	      </nav>
	    </div>
	  </header>
	<!--...-->
	```

- To uniquely identify each user, perform the migration

	`rails generate migration add_column_user_id_to_complaints user_id:integer`

- To let a user associate with multiple complaints, modify the User model (`app/model/user.rb`) to include the line

	```ruby
	has_many :complaints
	```

- Each complaint is tied to a single user and is validated by adding these lines to the Complaint model:

	```ruby
	belongs_to :user
	validates_presence_of :user
	```

- Update the Complaint controller to show only the user's complaints in his dashboard (the Index):

	```ruby
	def index
	  @complaints = Complaint.where(:user_id => current_user.id)
	end
	```

- Associate each complaint with the user ID on creation in the Complaint controller method:

	```ruby
	def create
	  @complaint = Complaint.new(complaint_params)
	  @complaint.user_id = current_user.id
	  respond_to do |format|
	  #...
	end
	```

* * *

### Objective 1:

- Add a boolean attribute 'admin' to every user by first:
	
	* Generating the migration:

		`rails g migration add_column_admin_to_user admin:boolean`

	* Before migrating, modify the migration to set the default value of the 'admin' attribute as False, then perform the migration:

		```ruby
		add_column :users, :admin, :boolean, default: false
		```

	* Finally using the Rails console (`rails c`), set a particular user to be the Administrator (or Admin) by updating the attribute 'admin' to True:

		```
		user = User.first (or any user of your choice)
		user.admin = True
		user.save
		```

		If no user has been created already, do so and set it to be the Admin. 

	* To test if a user is an admin, use the method 

		```ruby
		current_user.try(:admin?)
		```

* * *

### Objective 2:

- The objective is implicitly achieved i.e. all users can make a complaint by default.

* * *

### Objective 3 & 4:

- First generate a migration to add an attribute 'status' to every complaint:
	
	`rails g migration add_column_status_to_complaint status:string`

- Modify the migration to set the default value of 'status' to "Pending", 
	
	```ruby
	add_column :complaints, :status, :string, default: 'Pending'
	```

	then perform the migration.

- To check for the value of status, add these methods to the Complaint model:

	```ruby
	def processing?
	  status == "Processing"
  	end
  	def pending?
          status == "Pending"
  	end
  	def complete?
	  status == "Complete"
	end
  	```


- Define a new Complaint controller to update the status according to the specifications (using the PATCH method), and validate it against the user:

	```ruby
	def update_status
          new_status = @complaint.new_status(current_user)
          @complaint.update_attribute(:status, new_status)
	  redirect_to @complaint, notice: "Marked as " + new_status
        end
        ```

- Define a new function in the Complaint model to return the new status to update in the method above:

	```ruby
	def new_status(current_user)
	  new_status = status
	  if current_user.try(:admin?)
	    if pending?
	      new_status = 'Processing'
	    elsif processing?
	      new_status = 'Complete'
	    end
   	  elsif id == current_user.id && complete?
	    new_status = 'Resolved'
	  end
	  return new_status
	end
    ```

- To use the updated model and controller (also to differentiate between the User and Admin dashboards), edit the Index view (`index.html.erb`) to the following:

	```html+erb
	<!--...-->
	<td><%= link_to 'Delete', complaint, method: :delete, data: { confirm: 'Are you sure?' } %></td>>
	<!--...-->
	<% if current_user.try(:admin?) %>
	  <% if complaint.pending? %>
	    <td><%= link_to 'Mark as Processing', update_status_complaint_path(complaint), method: :patch %></td>
	  <% elsif complaint.processing? %>
	    <td><%= link_to 'Mark as Complete', update_status_complaint_path(complaint), method: :patch %></td>
	  <% end %>
	<% else %>
	   <% if complaint.pending? %>
	     <td>Pending</td>
	   <% elsif complaint.complete? %>
	     <td><%= link_to 'Mark as Resolved', update_status_complaint_path(complaint), method: :patch %></td>
	      <% end %>
	 <% end %>
	 <!--...-->
	 ```

- Add the corresponding method in the `routes.rb` file:

	```ruby
	#...
	resources :complaints do
	  member do
		patch :update_status
	  end
	end
	#...
	```

* * *

### Objective 5:

- For different dashboards (i.e. identify users and the Admin seperately), modify the main application header (in `application.html.erb`) to match the following:

	```html+erb
	<!--...-->
	<header class="navbar navbar-fixed-top navbar-inverse">
          <div class="container">
            <% if current_user.try(:admin?) %>
              ADMIN DASHBOARD
            <% elsif current_user %>
              <%= current_user.name %>'s dashboard
            <% end %>
            <nav>
        <!--...-->
        ```

- The methods `current_user.try(:admin?)` and `current_user` can be used to check if the user is signed in and is an Admin or a regular user, for further UI improvements (check the modified Index & Show Views for an example).

* * *

### Objective 6:

Disclaimer: This approach (specifically the JS function and HTML+ERB form) is not fully DRY due to issues I've run into with jQuery and Rails.

- To validate the title from the server-side (Model validation), add this line to the Complaint model:

	```ruby
	validates :title, presence: true
	```

- For client-side validation (View validation), first update `app/assets/javascripts/application.js` to include these three lines (before `//= require_tree .`)

	```ruby
	//= require jquery
	//= require jquery_ujs
	//= require bootstrap.min
	```

- Then, in that folder, create a new JavaScript file `inline_validation.js` with the following contents:

	```javascript
	function changeHandler() {
	  var complaint_title = $("#complaint_title").val();
	  var user_name = $("#user_name").val();
	  if (complaint_title || user_name ){
	      $("input[type=submit]").removeAttr("disabled");
	  } else {
	      $("input[type=submit]").attr("disabled", "disabled");
	  }
	}
	```

- Modify the form to match the following:

	```html+erb
	<!--...-->
	<div class="field">
          <%= form.label :title %>
          <%= form.text_field :title, onkeyup: "changeHandler()" %>
  	</div>
  	<!--...-->
  	<div class="actions">
          <%= form.submit id: "complaint_submit", disabled: "disabled" %>
  	</div>
  	<!--...-->
  	```

* * *

### Objective 7:

- Add the following field above the email field in `layouts/devise/new.html.erb` and `layouts/devise/edit.html.erb`:

	```html+erb
	<div class="field">
          <%= f.label :name %><br />
          <%= f.text_field :name, autofocus: true %>
  	</div>
  	```
	Also remove the 'autofocus' attribute from the email field.
		  
- Generate the User registration controller by the following command:

	`rails generate devise:controllers users -c=registrations`

- Navigate to `controllers/users/registrations_controller.rb` and override the parameters to include a name by adding the following lines:

	```ruby
	def sign_up_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
  	end
  	def account_update_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  	end
  	```

- To use this new controller as the User registrations controller, add it as a route to routes.rb:

	```ruby
	devise_for :users, controllers: { registrations: 'users/registrations' }
	```

- In the User model, to perform server-side validation, add the line

	```ruby
	validates :name, presence: true
	```

- For client-side validation, modify the text fields and the submit button by following the proceedure outlined in Objective 6.

* * *
