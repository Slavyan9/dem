DROP DATABASE IF EXISTS furniture_company;
CREATE DATABASE furniture_company;
USE furniture_company;

CREATE TABLE material_types (
    material_type_id INT AUTO_INCREMENT PRIMARY KEY,
    material_name VARCHAR(100) NOT NULL,
    waste_percentage DECIMAL(5,4) NOT NULL COMMENT 'Процент потерь сырья',
    description TEXT,
    is_eco_friendly BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (material_name)
) ENGINE=InnoDB;

CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    type_coefficient DECIMAL(5,2) NOT NULL COMMENT 'Коэффициент типа продукции',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (category_name)
) ENGINE=InnoDB;

CREATE TABLE workshops (
    workshop_id INT AUTO_INCREMENT PRIMARY KEY,
    workshop_name VARCHAR(100) NOT NULL,
    workshop_type VARCHAR(50) NOT NULL,
    workers_count INT NOT NULL COMMENT 'Количество человек для производства',
    location VARCHAR(100),
    manager_name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (workshop_name)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    article_number VARCHAR(20) NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    partner_min_price DECIMAL(10,2) NOT NULL COMMENT 'Минимальная стоимость для партнера',
    production_cost DECIMAL(10,2) COMMENT 'Себестоимость производства',
    weight_kg DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id),
    UNIQUE KEY (article_number),
    UNIQUE KEY (product_name)
) ENGINE=InnoDB;

CREATE TABLE product_materials (
    product_id INT NOT NULL,
    material_type_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL COMMENT 'Количество материала',
    unit VARCHAR(20) NOT NULL COMMENT 'Единица измерения',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, material_type_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (material_type_id) REFERENCES material_types(material_type_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE production_operations (
    operation_id INT AUTO_INCREMENT PRIMARY KEY,
    operation_name VARCHAR(100) NOT NULL,
    description TEXT,
    workshop_id INT NOT NULL,
    average_duration_hours DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id),
    UNIQUE KEY (operation_name, workshop_id)
) ENGINE=InnoDB;

CREATE TABLE product_operations (
    product_id INT NOT NULL,
    operation_id INT NOT NULL,
    sequence_order INT NOT NULL,
    duration_hours DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, operation_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (operation_id) REFERENCES production_operations(operation_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    material_type_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    min_stock_level DECIMAL(10,2) NOT NULL,
    last_restock_date DATE,
    next_restock_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (material_type_id) REFERENCES material_types(material_type_id)
) ENGINE=InnoDB;

CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    quantity_change DECIMAL(10,2) NOT NULL,
    transaction_type ENUM('incoming', 'outgoing', 'adjustment') NOT NULL,
    reference_id INT COMMENT 'ID связанного документа',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
) ENGINE=InnoDB;

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    workshop_id INT,
    hire_date DATE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id)
) ENGINE=InnoDB;

CREATE TABLE employee_skills (
    employee_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    proficiency_level ENUM('basic', 'intermediate', 'advanced', 'expert') NOT NULL,
    certified BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (employee_id, skill_name),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE production_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    start_date DATE NOT NULL,
    deadline DATE NOT NULL,
    status ENUM('planned', 'in_progress', 'completed', 'delayed', 'cancelled') NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE production_tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    operation_id INT NOT NULL,
    workshop_id INT NOT NULL,
    assigned_employee_id INT,
    planned_start DATETIME NOT NULL,
    planned_end DATETIME NOT NULL,
    actual_start DATETIME,
    actual_end DATETIME,
    status ENUM('not_started', 'in_progress', 'completed', 'on_hold') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES production_orders(order_id),
    FOREIGN KEY (operation_id) REFERENCES production_operations(operation_id),
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id),
    FOREIGN KEY (assigned_employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;


INSERT INTO material_types (material_name, waste_percentage) VALUES
('Мебельный щит из массива дерева', 0.008),
('Ламинированное ДСП', 0.007),
('Фанера', 0.0055),
('МДФ', 0.003);

INSERT INTO product_categories (category_name, type_coefficient) VALUES
('Гостиные', 3.5),
('Прихожие', 5.6),
('Мягкая мебель', 3.0),
('Кровати', 4.7),
('Шкафы', 1.5),
('Комоды', 2.3);

INSERT INTO workshops (workshop_name, workshop_type, workers_count) VALUES
('Проектный', 'Проектирование', 4),
('Расчетный', 'Проектирование', 5),
('Раскроя', 'Обработка', 5),
('Обработки', 'Обработка', 6),
('Сушильный', 'Сушка', 3),
('Покраски', 'Обработка', 5),
('Столярный', 'Обработка', 7),
('Изготовления изделий из искусственного камня и композитных материалов', 'Обработка', 3),
('Изготовления мягкой мебели', 'Обработка', 5),
('Монтажа стеклянных, зеркальных вставок и других изделий', 'Сборка', 2),
('Сборки', 'Сборка', 6),
('Упаковки', 'Сборка', 4);

INSERT INTO products (product_name, article_number, category_id, partner_min_price) VALUES
('Комплект мебели для гостиной Ольха горная', '1549922', 
  (SELECT category_id FROM product_categories WHERE category_name = 'Гостиные'), 160507.00),
('Стенка для гостиной Вишня темная', '1018556', 
  (SELECT category_id FROM product_categories WHERE category_name = 'Гостиные'), 216907.00),
('Прихожая Венге Винтаж', '3028272', 
  (SELECT category_id FROM product_categories WHERE category_name = 'Прихожие'), 24970.00),
('Тумба под ТВ', '4028048', 
  (SELECT category_id FROM product_categories WHERE category_name = 'Комоды'), 12350.00);

INSERT INTO product_materials (product_id, material_type_id, quantity, unit) VALUES
((SELECT product_id FROM products WHERE article_number = '1549922'),
 (SELECT material_type_id FROM material_types WHERE material_name = 'Мебельный щит из массива дерева'), 25.5, 'кг'),
 
((SELECT product_id FROM products WHERE article_number = '4028048'),
 (SELECT material_type_id FROM material_types WHERE material_name = 'МДФ'), 15.0, 'кг');

INSERT INTO production_operations (operation_name, workshop_id, average_duration_hours) VALUES
('Раскрой материала', 
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Раскроя'), 1.5),
('Шлифовка', 
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Обработки'), 0.8),
 
('Упаковка готовой продукции', 
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Упаковки'), 0.5);

INSERT INTO product_operations (product_id, operation_id, sequence_order, duration_hours) VALUES
((SELECT product_id FROM products WHERE article_number = '1549922'),
 (SELECT operation_id FROM production_operations WHERE operation_name = 'Раскрой материала'), 1, 1.0),

((SELECT product_id FROM products WHERE article_number = '4028048'),
 (SELECT operation_id FROM production_operations WHERE operation_name = 'Упаковка готовой продукции'), 5, 0.3);


INSERT INTO inventory (material_type_id, quantity, min_stock_level) VALUES
((SELECT material_type_id FROM material_types WHERE material_name = 'Мебельный щит из массива дерева'), 1500.00, 500.00),

((SELECT material_type_id FROM material_types WHERE material_name = 'МДФ'), 800.00, 300.00);


INSERT INTO employees (first_name, last_name, position, workshop_id, hire_date) VALUES
('Иван', 'Петров', 'Столяр', 
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Столярный'), '2020-05-15'),

('Анна', 'Сидорова', 'Упаковщик', 
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Упаковки'), '2021-11-03');


INSERT INTO production_orders (product_id, quantity, start_date, deadline, status, priority) VALUES
((SELECT product_id FROM products WHERE article_number = '1549922'), 10, '2023-06-01', '2023-06-15', 'planned', 'high'),

((SELECT product_id FROM products WHERE article_number = '4028048'), 25, '2023-06-05', '2023-06-20', 'in_progress', 'medium');


INSERT INTO production_tasks (order_id, operation_id, workshop_id, planned_start, planned_end, status) VALUES
(1, 
 (SELECT operation_id FROM production_operations WHERE operation_name = 'Раскрой материала'),
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Раскроя'),
 '2023-06-01 08:00:00', '2023-06-01 12:00:00', 'not_started'),

(2, 
 (SELECT operation_id FROM production_operations WHERE operation_name = 'Упаковка готовой продукции'),
 (SELECT workshop_id FROM workshops WHERE workshop_name = 'Упаковки'),
 '2023-06-18 10:00:00', '2023-06-18 12:30:00', 'not_started');