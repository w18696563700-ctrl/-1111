import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_listing' })
export class EnterpriseListingEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'primary_board_type', type: 'varchar', length: 32 })
  primaryBoardType!: string;

  @Column({ name: 'secondary_capabilities', type: 'jsonb', default: () => "'[]'" })
  secondaryCapabilities!: string[];

  @Column({ type: 'varchar', length: 128, default: '' })
  name!: string;

  @Column({ name: 'short_intro', type: 'text', default: '' })
  shortIntro!: string;

  @Column({ name: 'full_intro', type: 'text', nullable: true })
  fullIntro!: string | null;

  @Column({ name: 'logo_file_asset_id', type: 'varchar', length: 64, nullable: true })
  logoFileAssetId!: string | null;

  @Column({ name: 'cover_file_asset_id', type: 'varchar', length: 64, nullable: true })
  coverFileAssetId!: string | null;

  @Column({
    name: 'album_image_file_asset_ids',
    type: 'jsonb',
    default: () => "'[]'",
  })
  albumImageFileAssetIds!: string[];

  @Column({ name: 'province_code', type: 'varchar', length: 32, default: '' })
  provinceCode!: string;

  @Column({ name: 'province_name', type: 'varchar', length: 64, default: '' })
  provinceName!: string;

  @Column({ name: 'city_code', type: 'varchar', length: 32, default: '' })
  cityCode!: string;

  @Column({ name: 'city_name', type: 'varchar', length: 64, default: '' })
  cityName!: string;

  @Column({ name: 'district_code', type: 'varchar', length: 32, nullable: true })
  districtCode!: string | null;

  @Column({ name: 'district_name', type: 'varchar', length: 64, nullable: true })
  districtName!: string | null;

  @Column({ type: 'text', nullable: true })
  address!: string | null;

  @Column({ name: 'public_display_address', type: 'text', nullable: true })
  publicDisplayAddress!: string | null;

  @Column({ type: 'double precision', nullable: true })
  latitude!: number | null;

  @Column({ type: 'double precision', nullable: true })
  longitude!: number | null;

  @Column({ name: 'geo_source', type: 'varchar', length: 64, nullable: true })
  geoSource!: string | null;

  @Column({ name: 'geo_status', type: 'varchar', length: 32, nullable: true })
  geoStatus!: string | null;

  @Column({ name: 'last_geocoded_at', type: 'timestamptz', nullable: true })
  lastGeocodedAt!: Date | null;

  @Column({ name: 'map_provider', type: 'varchar', length: 32, nullable: true })
  mapProvider!: string | null;

  @Column({ name: 'founded_at', type: 'date', nullable: true })
  foundedAt!: string | null;

  @Column({ name: 'team_size_range', type: 'varchar', length: 32, nullable: true })
  teamSizeRange!: string | null;

  @Column({ name: 'cooperation_modes', type: 'jsonb', default: () => "'[]'" })
  cooperationModes!: string[];

  @Column({ name: 'legal_name_snapshot', type: 'varchar', length: 256, nullable: true })
  legalNameSnapshot!: string | null;

  @Column({
    name: 'unified_social_credit_code_snapshot',
    type: 'varchar',
    length: 64,
    nullable: true
  })
  unifiedSocialCreditCodeSnapshot!: string | null;

  @Column({ name: 'verification_status_snapshot', type: 'varchar', length: 32, nullable: true })
  verificationStatusSnapshot!: string | null;

  @Column({ name: 'enterprise_status', type: 'varchar', length: 32, default: 'unpublished' })
  enterpriseStatus!: string;

  @Column({ name: 'display_status', type: 'varchar', length: 32, default: 'hidden' })
  displayStatus!: string;

  @Column({ name: 'contact_visible', type: 'boolean', default: false })
  contactVisible!: boolean;

  @Column({ name: 'published_at', type: 'timestamptz', nullable: true })
  publishedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
