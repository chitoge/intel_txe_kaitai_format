meta:
  id: cstxe_v3_flash
  endian: le
seq:
  - id: sig_or_romb
    type: u4
instances:
  romb_size:
    value: 'sig_or_romb == 0x54504624 ? 0 : 16'
  fpt_region:
    pos: romb_size
    type: fpt_region_type
types:
  fpt_header:
    seq:
      - id: fpt_sig
        contents: '$FPT'
      - id: num_partitions
        type: u4
      - id: header_version
        type: u1
      - id: entry_version
        type: u1
      - id: header_length
        type: u1
      - id: header_checksum
        type: u1
      - id: flash_cycle_life
        type: u2
      - id: flash_cycle_limit
        type: u2
      - id: uma_size
        type: u4
      - id: flags
        type: u4
      - id: fit_major
        type: u2
      - id: fit_minor
        type: u2
      - id: fit_hotfix
        type: u2
      - id: fit_build
        type: u2
  cpd_header:
    seq:
      - id: tag
        contents: '$CPD'
      - id: num_modules
        type: u4
      - id: header_version
        type: u1
      - id: entry_version
        type: u1
      - id: header_length
        type: u1
      - id: checksum
        type: u1
      - id: partition_name
        type: str
        encoding: ASCII
        size: 4
      - id: checksum_v2
        type: u4
        if: header_version == 2
  cpd_entry_offset_attribute:
    seq:
      - id: u32
        type: u4
    instances:
      offset_from_cpd:
        value: '((u32 & (1 << 25)) != 0) ? (u32 ^ (1 << 25)) : u32'
      is_huffman:
        value: '((u32 & (1 << 25)) != 0) ? true : false'
  cpd_entry:
    seq:
      - id: name
        type: str
        encoding: ASCII
        size: 12
      - id: offset_attribute
        type: cpd_entry_offset_attribute
      - id: size
        type: u4
      - type: u4
  mn2_manifest_r0_metadata:
    seq:
      - id: security_version_number_8
        type: u4
      - id: version_control_number
        type: u4
      - type: u4
        repeat: expr
        repeat-expr: 16
      - id: public_key_size
        type: u4
      - id: exponent_size
        type: u4
      - id: rsa_public_key
        type: u4
        repeat: expr
        repeat-expr: public_key_size
      - id: rsa_exponent
        type: u4
        repeat: expr
        repeat-expr: exponent_size
      - id: rsa_signature
        type: u4
        repeat: expr
        repeat-expr: public_key_size
  mn2_manifest_r1_metadata:
    seq:
      - id: meu_major
        type: u2
      - id: meu_minor
        type: u2
      - id: meu_hotfix
        type: u2
      - id: meu_build
        type: u2
      - id: meu_man_ver
        type: u2
      - id: meu_man_res
        type: u2
      - type: u4
        repeat: expr
        repeat-expr: 15
      - id: public_key_size
        type: u4
      - id: exponent_size
        type: u4
      - id: rsa_public_key
        type: u4
        repeat: expr
        repeat-expr: public_key_size
      - id: rsa_exponent
        type: u4
        repeat: expr
        repeat-expr: exponent_size
      - id: rsa_signature
        type: u4
        repeat: expr
        repeat-expr: public_key_size
  mn2_manifest:
    seq:
      - id: header_type
        type: u2
      - id: header_subtype
        type: u2
      - id: header_length
        type: u4
      - id: header_version
        type: u4
      - id: debug_signed
        type: b1
      - id: preproduction
        type: b1
      - type: b29
      - id: pvbit
        type: b1
      - id: vendor_id
        type: u4
      - id: day
        type: u1
      - id: month
        type: u1
      - id: year
        type: u2
      - id: size
        type: u4
      - id: tag
        contents: '$MN2'
      - id: internal_info
        type: u4
      - id: major
        type: u2
      - id: minor
        type: u2
      - id: hotfix
        type: u2
      - id: build
        type: u2
      - id: security_version_number
        type: u4
      - id: metadata
        type: mn2_manifest_r1_metadata
  cpd_region:
    seq:
      - id: header
        type: cpd_header
      - id: entries
        type: cpd_entry
        repeat: expr
        repeat-expr: header.num_modules
      - id: manifest
        type: mn2_manifest
  fpt_entry:
    seq:
      - id: name
        size: 4
        type: str
        encoding: ASCII
      - id: owner
        size: 4
        type: str
        encoding: ASCII
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: start_tokens
        type: u4
      - id: max_tokens
        type: u4
      - id: scratch_sectors
        type: u4
      - id: flag_type
        type: b7
        enum: fpt_partition_type
      - type: b8
      - id: flag_bwl0
        type: b1
      - id: flag_bwl1
        type: b1
      - type: b7
      - id: flag_entry_valid
        type: b8
    enums:
      fpt_partition_type:
        0: code
        1: data
        2: nvram
        3: generic
        4: effs
        5: rom
    instances:
      cpd_check:
        pos: offset
        type: u4
      cpd_region:
        pos: offset
        type: cpd_region
        if: cpd_check == 0x44504324
  fpt_region_type:
    seq:
      - id: header
        type: fpt_header
      - id: entries
        type: fpt_entry
        repeat: expr
        repeat-expr: header.num_partitions
