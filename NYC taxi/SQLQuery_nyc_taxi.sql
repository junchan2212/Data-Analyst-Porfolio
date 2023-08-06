-- view tables
Select TOP 20 * 
From fact_table


-- The most pick up locations
Select Top 20 
	fact_table.PULocationID, taxizone_lookup.Borough, taxizone_lookup.Zone, COUNT(fact_table.trip_ID) as no_trips,
	AVG(fact_table.passenger_count) as avg_passenger
From fact_table
	Left join taxizone_lookup
	On fact_table.PULocationID = taxizone_lookup.LocationID
Group by fact_table.PULocationID, taxizone_lookup.Borough, taxizone_lookup.Zone
Order by no_trips desc


-- The most drop off locations
Select Top 20 
	fact_table.DOLocationID, taxizone_lookup.Borough, taxizone_lookup.Zone, 
	COUNT(fact_table.trip_ID) as no_trips, 
	AVG(fact_table.passenger_count) as avg_passenger
From fact_table
	Left join taxizone_lookup
	On fact_table.DOLocationID = taxizone_lookup.LocationID
Group by fact_table.DOLocationID, taxizone_lookup.Borough, taxizone_lookup.Zone
Order by no_trips desc

-- Trips, Total Charges, Total Charges per Trip of Vendors
Select fact_table.VendorID, Vendor_lookup.Vendor_name,
	COUNT(fact_table.trip_ID) as no_trips,
	SUM(cast(fact_table.total_charges as float)) as total_charges,
	(SUM(cast(fact_table.total_charges as float)))/(COUNT(fact_table.trip_ID))
From fact_table 
	Left join Vendor_lookup 
	ON fact_table.VendorID = Vendor_lookup.VendorID
Group by fact_table.VendorID, Vendor_lookup.Vendor_name
Order by no_trips desc

-- Most popular payment methods
Select Payment_lookup.Payment_type, COUNT(fact_table.trip_ID) as no_trips
From fact_table
	Left join Payment_lookup
	ON fact_table.payment_type = payment_lookup.Payment_typeID
Group by Payment_lookup.Payment_type
Order by no_trips desc

--
select * from RateCode_lookup