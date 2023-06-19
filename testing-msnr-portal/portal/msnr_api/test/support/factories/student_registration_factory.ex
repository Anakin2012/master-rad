defmodule MsnrApi.StudentRegistrationFactory do

  alias MsnrApi.Queries.StudentRegistrationsTest
  alias MsnrApi.StudentRegistrations.StudentRegistration
  alias MsnrApi.Semesters

  defmacro __using__(_opts) do
    quote do
      def student_registration_factory do
        %StudentRegistration {
          semester_id: Semesters.get_active_semester!().id,
          email: Faker.Internet.email(),
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          index_number: Faker.Lorem.word()
        }
      end
    end
  end
end
