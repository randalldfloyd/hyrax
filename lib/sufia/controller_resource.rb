module Sufia
  # Overrides CanCan so that attributes are not automatically assigned
  # to loaded resources
  class ControllerResource < CanCan::ControllerResource
    protected

      # Override resource_params to make this a nop. Sufia uses actors to assign attributes
      def resource_params
        {}
      end
  end
end
