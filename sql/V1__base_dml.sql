CREATE TYPE client_auth_method AS ENUM ('client_secret_post', 'client_secret_basic', 'client_secret_jwt', 'private_key_jwt', 'none');

create sequence t_role_role_id_seq;
create sequence t_privilege_privilege_id_seq;
create sequence t_user_role_user_role_id_seq;
create sequence t_role_privilege_role_privilege_id_seq;
create sequence t_user_privilege_user_privilege_id_seq;
create sequence t_person_person_id_seq;
create sequence t_address_address_id_seq;
create sequence t_contact_info_contact_info_id_seq;
create sequence t_category_category_id_seq;
create sequence t_item_item_id_seq;
create sequence t_inventory_inventory_id_seq;
create sequence t_unit_unit_id_seq;
create sequence t_inventory_item_inventory_item_id_seq;
create sequence t_inventory_order_inventory_order_id_seq;
create sequence t_order_order_id_seq;
create sequence t_maintenance_maintenance_id_seq;
create sequence t_maint_equipment_maint_equipment_id_seq;
create sequence t_task_task_id_seq;
create sequence t_sub_task_sub_task_id_seq;
create sequence t_task_trigger_task_trigger_id_seq;
create sequence t_task_resource_task_resource_id_seq;
create sequence t_work_order_work_order_id_seq;
create sequence t_work_queue_work_queue_id_seq;
create sequence t_work_order_resource_work_order_resource_id_seq;
create sequence t_work_order_sub_task_work_order_sub_task_id_seq;


CREATE TABLE oauth2_client (
    id text PRIMARY KEY,
    secret text,
    authorized_grant_types text[],
    redirect_uri text[],
    access_token_validity integer NOT NULL,
    refresh_token_validity integer NOT NULL,
    allowed_scope text[],
    auto_approve boolean DEFAULT FALSE,
    auth_method client_auth_method NOT NULL,
    auth_alg text,
    keys_uri text,
    keys jsonb,
    id_token_algs jsonb,
    user_info_algs jsonb,
    request_obj_algs jsonb,
    sector_identifier text NOT NULL
);

CREATE TABLE authz_code (
    code text PRIMARY KEY,
    uid  text NOT NULL,
    client_id text NOT NULL REFERENCES oauth2_client,
    issued_at timestamptz NOT NULL,
    scope text[] NOT NULL,
    nonce text NULL,
    uri   text NULL,
    auth_time timestamptz NOT NULL
);

CREATE TABLE authz_approval (
    uid text,
    client_id text REFERENCES oauth2_client,
    scope text[] NOT NULL,
    denied_scope text[] NOT NULL,
    expires_at timestamptz NOT NULL,
    PRIMARY KEY (uid, client_id)
);

-- BUSINESS ADMIN TABLES
create table t_person (
    person_id     bigint default nextval('t_person_person_id_seq'::regclass) not null constraint t_person_pkey primary key,
    first_name    varchar                                                    not null,
    last_name     varchar                                                    not null,
    document_type varchar                                                    not null,
    document_id   varchar                                                    not null constraint unique_person_document_id unique,
    created_date  timestamp with time zone                                   not null,
    modified_date timestamp with time zone
);

create table t_address (
    address_id    bigint default nextval('t_address_address_id_seq'::regclass) not null constraint t_address_pkey primary key,
    street1       varchar                                                      not null,
    street2       varchar                                                      not null,
    street3       varchar                                                      not null,
    zip           varchar                                                      not null,
    city          varchar                                                      not null,
    state         varchar                                                      not null,
    country       varchar                                                      not null,
    person_id     bigint not null constraint unique_address_person_id unique constraint t_address_person_id_fkey references t_person,
    created_date  timestamp with time zone                                     not null,
    modified_date timestamp with time zone
);

create table t_contact_info (
    contact_info_id bigint default nextval('t_contact_info_contact_info_id_seq'::regclass) not null constraint t_contact_info_pkey primary key,
    contact_type    varchar                                                                not null,
    contact         varchar                                                                not null,
    person_id       bigint                                                                 not null constraint t_contact_info_person_id_fkey references t_person,
    created_date    timestamp with time zone                                               not null,
    modified_date   timestamp with time zone
);

create table t_role (
    role_id       bigint default nextval('t_role_role_id_seq'::regclass)                not null constraint t_role_pkey primary key,
    key           varchar                  not null,
    name          varchar                  not null,
    description   varchar,
    active        boolean                  not null,
    created_date  timestamp with time zone not null,
    modified_date timestamp with time zone
);

create table t_privilege (
    privilege_id  bigint default nextval('t_privilege_privilege_id_seq'::regclass) not null constraint t_privilege_pkey primary key,
    key           varchar                                                          not null,
    name          varchar                                                          not null,
    description   varchar,
    active        boolean                                                          not null,
    created_date  timestamp with time zone                                         not null,
    modified_date timestamp with time zone
);

create table t_user (
    user_id               bigint not null constraint t_user_pkey primary key constraint t_user_user_id_fkey references t_person,
    username              varchar                  not null constraint unique_user_username unique,
    email                 varchar                  not null constraint unique_user_email unique,
    password              varchar                  not null,
    status                varchar                  not null,
    locale                varchar                  not null,
    expiration            boolean                  not null,
    new_password_required boolean                  not null,
    created_date          timestamp with time zone not null,
    modified_date         timestamp with time zone
);

create table t_category (
    category_id   bigint default nextval('t_category_category_id_seq'::regclass)                not null constraint t_category_pkey primary key,
    key           varchar,
    name          varchar                  not null,
    description   varchar                  not null,
    scope         varchar                  not null,
    created_date  timestamp with time zone not null,
    modified_date timestamp with time zone
);

create table t_employee (
    employee_id           bigint not null constraint t_employee_pkey primary key constraint t_employee_employee_id_fkey references t_person,
    salary                double precision         not null,
    employee_category_id  bigint                   not null constraint t_employee_employee_category_id_fkey references t_category,
    created_date  timestamp with time zone         not null,
    modified_date timestamp with time zone
);

create table t_supplier (
    supplier_id   bigint not null constraint t_supplier_pkey primary key constraint t_supplier_supplier_id_fkey references t_person,
    name          varchar                                                        not null,
    webpage       varchar                                                        not null,
    status        varchar                                                        not null,
    created_date  timestamp with time zone                                       not null,
    modified_date timestamp with time zone
);

create table t_user_role (
    user_role_id bigint default nextval('t_user_role_user_role_id_seq'::regclass) not null constraint t_user_role_pkey primary key,
    user_id      bigint    not null constraint t_user_role_user_id_fkey references t_user,
    role_id      bigint    not null constraint t_user_role_role_id_fkey references t_role
);

create table t_role_privilege (
    role_privilege_id bigint default nextval('t_role_privilege_role_privilege_id_seq'::regclass) not null constraint t_role_privilege_pkey primary key,
    role_id           bigint                                                                     not null constraint t_role_privilege_role_id_fkey references t_role,
    privilege_id      bigint                                                                     not null constraint t_role_privilege_privilege_id_fkey references t_privilege
);

create table t_user_privilege (
    user_privilege_id bigint default nextval('t_user_privilege_user_privilege_id_seq'::regclass) not null constraint t_user_privilege_pkey primary key,
    user_id           bigint                                                                     not null constraint t_user_privilege_user_id_fkey references t_user,
    privilege_id      bigint                                                                     not null constraint t_user_privilege_privilege_id_fkey references t_privilege
);

create table t_inventory (
    inventory_id          bigint default nextval('t_inventory_inventory_id_seq'::regclass) not null constraint t_inventory_pkey primary key,
    name                  varchar                                                          not null constraint unique_inventory_name unique,
    description           varchar                                                          not null,
    status                varchar                                                          not null,
    allow_negative_stocks boolean                                                          not null,
    created_date          timestamp with time zone                                         not null,
    modified_date         timestamp with time zone
);

create table t_unit (
    unit_id       bigint default nextval('t_unit_unit_id_seq'::regclass) not null constraint t_unit_pkey primary key,
    key           varchar                                                not null,
    label         varchar                                                not null,
    created_date  timestamp with time zone                               not null,
    modified_date timestamp with time zone
);

create table t_item (
    item_id       bigint default nextval('t_item_item_id_seq'::regclass) not null constraint t_item_pkey primary key,
    code          varchar                  not null,
    name          varchar                  not null,
    default_price double precision         not null,
    description   varchar,
    images        varchar                  not null,
    part_number   varchar,
    manufacturer  varchar,
    model         varchar,
    item_type     varchar                  not null,
    notes         varchar,
    status        varchar                  not null,
    category_id   bigint        constraint t_item_category_id_fkey references t_category,
    unit_id       bigint        constraint t_item_unit_id_fkey     references t_unit,
    created_date  timestamp with time zone not null,
    modified_date timestamp with time zone
);

create table t_inventory_item (
    inventory_item_id bigint default nextval('t_inventory_item_inventory_item_id_seq'::regclass) not null constraint t_inventory_item_pkey primary key,
    level             bigint                   not null,
    max_level_allowed bigint                   not null,
    min_level_allowed bigint                   not null,
    price             double precision         not null,
    location          varchar                  not null,
    date_expiry       timestamp with time zone,
    item_id           bigint                   not null constraint t_inventory_item_item_id_fkey references t_item,
    inventory_id      bigint                   not null constraint t_inventory_item_inventory_id_fkey references t_inventory,
    created_date      timestamp with time zone not null,
    modified_date     timestamp with time zone,
    status            varchar                  not null,
    constraint unique_inventory_id_item_id unique (inventory_id, item_id)
);

create table t_order (
    order_id            bigint default nextval('t_order_order_id_seq'::regclass) not null constraint t_order_pkey primary key,
    discount            double precision         not null,
    order_date          timestamp with time zone not null,
    delivered_lead_time timestamp with time zone not null,
    status              varchar                  not null,
    notes               varchar                  not null,
    inventory_id        bigint                   not null constraint t_order_inventory_id_fkey references t_inventory,
    supplier_id         bigint                   not null constraint t_order_supplier_id_fkey references t_supplier,
    emitter_id          bigint                   not null constraint t_order_emitter_id_fkey references t_user,
    created_date        timestamp with time zone not null,
    modified_date       timestamp with time zone
);

create table t_inventory_order (
    inventory_order_id bigint default nextval('t_inventory_order_inventory_order_id_seq'::regclass) not null constraint t_inventory_order_pkey primary key,
    quantity                bigint                                          not null,
    price                   double precision                                not null,
    discount                double precision                                not null,
    sub_total_price         double precision                                not null,
    notes                   varchar                                         not null,
    inventory_item_id       bigint                                          not null constraint t_inventory_order_inventory_item_id_fkey references t_inventory_item,
    order_id                bigint                                          not null constraint t_inventory_order_order_id_fkey references t_order,
    created_date            timestamp with time zone                        not null,
    modified_date           timestamp with time zone
);

create table t_maintenance (
    maintenance_id bigint default nextval('t_maintenance_maintenance_id_seq'::regclass) not null constraint t_maintenance_pkey primary key,
    name           varchar                  not null,
    description    varchar,
    status         varchar                  not null,
    created_date   timestamp with time zone not null,
    modified_date  timestamp with time zone
);

create table t_equipment (
    equipment_id            bigint                   not null constraint t_equipment_pkey primary key constraint t_equipment_item_id_fkey references t_item,
    priority                bigint                   not null,
    hours_average_daily_use bigint                   not null,
    out_of_service          boolean                  not null,
    purchase_date           timestamp with time zone,
    parent_id               bigint constraint t_equipment_parent_id_fkey references t_item,
--     maintenance_id          bigint constraint t_equipment_maintenance_id_fkey references t_maintenance,
    created_date            timestamp with time zone not null,
    modified_date           timestamp with time zone
);

create table t_maint_equipment (
    maint_equipment_id      bigint default nextval('t_maint_equipment_maint_equipment_id_seq'::regclass) not null constraint t_maint_equipment_pkey primary key,
    equipment_id            bigint constraint t_maint_equipment_equipment_id_fkey references t_equipment,
    maintenance_id          bigint constraint t_maint_equipment_maintenance_id_fkey references t_maintenance
);

create table t_task (
    task_id            bigint default nextval('t_task_task_id_seq'::regclass) not null constraint t_task_pkey primary key,
    name               varchar                  not null,
    description        varchar,
    priority           bigint                   not null,
    duration           bigint                   not null,
    down_time_duration bigint                   not null,
    attribute1         varchar,
    attribute2         varchar,
    created_date       timestamp with time zone not null,
    modified_date      timestamp with time zone,
    task_category_id   bigint constraint t_task_task_category_id_fkey references t_category,
    maintenance_id     bigint constraint t_task_maintenance_id_fkey references t_maintenance
);

create table t_sub_task (
    sub_task_id          bigint default nextval('t_sub_task_sub_task_id_seq'::regclass) not null constraint t_sub_task_pkey primary key,
    "order"              bigint                   not null,
    "group"              varchar                  not null,
    description          varchar,
    mandatory            boolean                  not null,
    task_id              bigint                   not null constraint t_sub_task_task_id_fkey references t_task,
    sub_task_category_id bigint constraint t_sub_task_sub_task_category_id_fkey references t_category,
    created_date         timestamp with time zone not null,
    modified_date        timestamp with time zone
);

create table t_task_trigger (
    task_trigger_id           bigint default nextval('t_task_trigger_task_trigger_id_seq'::regclass) not null constraint t_task_trigger_pkey primary key,
    trigger_type              varchar                  not null,
    description               varchar                  not null,
    fixed_schedule            boolean,
    frequency                 bigint,
    read_type                 varchar,
    "limit"                   varchar,
    repeat                    boolean,
    operator                  varchar,
    value                     varchar,
    time_frequency            varchar,
    unit_id                   bigint constraint t_task_trigger_unit_id_fkey references t_unit,
    event_trigger_category_id bigint constraint t_task_trigger_event_trigger_category_id_fkey references t_category,
    task_id                   bigint                   not null constraint t_task_trigger_task_id_fkey references t_task,
    created_date              timestamp with time zone not null,
    modified_date             timestamp with time zone
);

create table t_task_resource (
    task_resource_id      bigint default nextval('t_task_resource_task_resource_id_seq'::regclass) not null constraint t_task_resource_pkey primary key,
    "order"               bigint                   not null,
    amount                bigint                   not null,
--    resource_type         varchar                  not null,
    unit_id               bigint                   not null constraint t_task_resource_unit_id_fkey references t_unit,
    employee_category_id  bigint constraint t_task_resource_employee_category_id_fkey references t_category,
    inventory_resource_id bigint constraint t_task_resource_inventory_resource_id_fkey references t_item,
    task_id               bigint                   not null constraint t_task_resource_task_id_fkey references t_task,
    created_date          timestamp with time zone not null,
    modified_date         timestamp with time zone
);

create table t_work_order (
    work_order_id      bigint default nextval('t_work_order_work_order_id_seq'::regclass) not null constraint t_work_order_pkey primary key,
    work_order_code    varchar                  not null,
    work_order_status  varchar                  not null,
    estimate_duration  bigint                   not null,
    execution_duration bigint                   not null,
    rate               bigint                   not null,
    total_cost         double precision         not null,
    percentage         double precision         not null,
    notes              varchar                  not null,
    generated_by_id    bigint constraint t_work_order_generated_by_id_fkey references t_user,
    responsible_id     bigint constraint t_work_order_responsible_id_fkey references t_user,
    canceled_by_id     bigint constraint t_work_order_canceled_by_id_fkey references t_user,
    parent_id          bigint constraint t_work_order_parent_id_fkey references t_work_order,
    close_date         timestamp with time zone,
    created_date       timestamp with time zone not null,
    modified_date      timestamp with time zone
);

create table t_work_queue (
    work_queue_id           bigint default nextval('t_work_queue_work_queue_id_seq'::regclass) not null constraint t_work_queue_pkey primary key,
    rescheduled_date        timestamp with time zone,
    scheduled_date          timestamp with time zone not null,
    incident_date           timestamp with time zone,
    work_type               varchar                  not null,
    status                  varchar                  not null,
    equipment_id            bigint                   not null constraint t_work_queue_equipment_id_fkey references t_equipment,
    task_id                 bigint                   not null constraint t_work_queue_task_id_fkey references t_task,
    task_trigger_id         bigint                   not null constraint t_work_queue_task_trigger_id_fkey references t_task_trigger,
    reported_by_id          bigint constraint t_work_queue_reported_by_id_fkey references t_user,
    work_order_id           bigint constraint t_work_queue_work_order_id_fkey references t_work_order,
    maintenance_id          bigint constraint t_work_queue_maintenance_id_fkey references t_maintenance,
    created_date            timestamp with time zone not null,
    modified_date           timestamp with time zone,
    out_of_service_interval bigint                   not null,
    start_work_date         timestamp with time zone,
    finished_work_date      timestamp with time zone,
    notes                   varchar
);

create table t_work_order_resource (
    work_order_resource_id bigint default nextval('t_work_order_resource_work_order_resource_id_seq'::regclass) not null constraint t_work_order_resource_pkey primary key,
    amount                 bigint                   not null,
    human_resource_id      bigint constraint t_work_order_resource_human_resource_id_fkey references t_person,
    inventory_item_id      bigint constraint t_work_order_resource_inventory_item_id_fkey references t_inventory_item,
    work_queue_id          bigint                   not null constraint t_work_order_resource_work_queue_id_fkey references t_work_queue,
    created_date           timestamp with time zone not null,
    modified_date          timestamp with time zone,
    resource_type          varchar                  not null,
    employee_category_id   bigint constraint t_work_order_resource_employee_category_id_fkey references t_category,
    item_id                bigint constraint t_work_order_resource_item_id_fkey references t_item
);

create table t_work_order_sub_task (
    work_order_sub_task_id bigint default nextval('t_work_order_sub_task_work_order_sub_task_id_seq'::regclass) not null constraint t_work_order_sub_task_pkey primary key,
    sub_task_id            bigint                   not null constraint t_work_order_sub_task_sub_task_id_fkey references t_sub_task,
    work_queue_id          bigint                   not null constraint t_work_order_sub_task_work_queue_id_fkey references t_work_queue,
    value                  varchar                  not null,
    created_date           timestamp with time zone not null,
    modified_date          timestamp with time zone
);
