------CREATING THE Tables --------------------------

CREATE TABLE [customers] (
    [cust_id] int  NOT NULL ,
    [cust_firstname] varchar(50)  NOT NULL ,
    [cust_lastname] varchar(50)  NOT NULL ,
    CONSTRAINT [PK_customers] PRIMARY KEY CLUSTERED (
        [cust_id] ASC
    )
)

CREATE TABLE [address] (
    [add_id] int  NOT NULL ,
    [delivery_address1] varchar(200)  NOT NULL ,
    [delivery_address2] varchar(200)  NOT NULL ,
    [delivery_city] varchar(50)  NOT NULL ,
    [delivery_zipcode] varchar(20)  NOT NULL ,
    CONSTRAINT [PK_address] PRIMARY KEY CLUSTERED (
        [add_id] ASC
    )
)

CREATE TABLE [orders] (
    [row_id] int  NOT NULL ,
    [order_id] varchar(10)  NOT NULL ,
    [created_at] datetime  NOT NULL ,
    [item_id] varchar(10)  NOT NULL ,
    [quantity] int  NOT NULL ,
    [cust_id] int  NOT NULL ,
    [delivery] BIT  NOT NULL ,
    [add_id] int  NOT NULL ,
    CONSTRAINT [PK_orders] PRIMARY KEY CLUSTERED (
        [row_id] ASC
    )
)

CREATE TABLE [items] (
    [item_id] varchar(10)  NOT NULL ,
    [sku] varchar(20)  NOT NULL ,
    [item_name] varchar(100)  NOT NULL ,
    [item_cat] varchar(100)  NOT NULL ,
    [item_size] varchar(10)  NOT NULL ,
    [item_price] decimal(5,2)  NOT NULL ,
    CONSTRAINT [PK_items] PRIMARY KEY CLUSTERED (
        [item_id] ASC
    )
)


CREATE TABLE [rota] (
    [row_id] int  NOT NULL ,
    [rota_id] varchar(20)  NOT NULL ,
    [date] datetime  NOT NULL ,
    [shift_id] varchar(20)  NOT NULL ,
    [staff_id] varchar(20)  NOT NULL ,
    CONSTRAINT [PK_rota] PRIMARY KEY CLUSTERED (
        [row_id] ASC
    )
)

CREATE TABLE [staff] (
    [staff_id] varchar(20)  NOT NULL ,
    [first_name] varchar(50)  NOT NULL ,
    [last_name] varchar(50)  NOT NULL ,
    [position] varchar(100)  NOT NULL ,
    [hourly_date] decimal(5,2)  NOT NULL ,
    CONSTRAINT [PK_staff] PRIMARY KEY CLUSTERED (
        [staff_id] ASC
    )
)

CREATE TABLE [shift] (
    [shift_id] varchar(20)  NOT NULL ,
    [day_of_week] varchar(10)  NOT NULL ,
    [start_time] time  NOT NULL ,
    [end_time] time  NOT NULL ,
    CONSTRAINT [PK_shift] PRIMARY KEY CLUSTERED (
        [shift_id] ASC
    )
)

-------------- Connecting the tables via PK and FK -----------------

ALTER TABLE orders
ADD CONSTRAINT FK_orders_item_id
FOREIGN KEY (item_id) REFERENCES items(item_id);

ALTER TABLE orders
ADD CONSTRAINT FK_orders_cust_id
FOREIGN KEY (cust_id) REFERENCES customers(cust_id);

ALTER TABLE orders
ADD CONSTRAINT FK_orders_add_id
FOREIGN KEY (add_id) REFERENCES address(add_id);


ALTER TABLE rota
ADD CONSTRAINT FK_rota_shift_id
FOREIGN KEY (shift_id) REFERENCES shift(shift_id);

ALTER TABLE rota
ADD CONSTRAINT FK_rota_staff_id
FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

-------------------- Querying through the Tables--------------------------------

select
	*
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id

-- Total Order

select
	count(order_id) as total_order
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id

-- Total Item sold
select
	sum(quantity) as total_item_sold
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id

-- Total sales in price

select
	sum(item_price) as total_sale
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id

-- Total items sold in each category

select
	sum(quantity) as total_item_sold, item_cat
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id
group by item_cat

-- Top selling item

select
	o.item_id, i.item_name, sum(quantity) as total_item_sold
from	
	orders o	left join	items i	on o.item_id = i.item_id
				left join	address a on o.add_id = a.add_id
group by o.item_id, i.item_name
order by total_item_sold DESC

-- Finding total hours worked and total wages for each staff by each shift 

select 
	 r.date, 
	 day_of_week, 
	 r.shift_id, 
	 r.staff_id,
	 CAST((((DATEDIFF(hour,start_time, end_time)*60)+DATEDIFF(MINUTE,start_time, end_time))/60) AS DECIMAL (4,2)) as total_hours_worked, 
	 (DATEDIFF(MINUTE,start_time, end_time)*(hourly_date/60)) as Wage 
from 
	rota r	left join staff s on r.staff_id = s.staff_id
			left join shift sh on r.shift_id = sh.shift_id