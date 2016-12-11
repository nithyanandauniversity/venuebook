module Venuebook

   class CenterAPI < Grape::API
      namespace "center" do
	 post do
	    Center.create(params)
	 end

	 post "/:id/address" do
	    center = Center.find(id: params[:id])
	    center.add_address(params[:address])
	 end
      end
   end
end

