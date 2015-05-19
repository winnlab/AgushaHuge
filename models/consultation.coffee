mongoose = require 'mongoose'
moment = require 'moment'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

schema = new mongoose.Schema
  name:
    type: String
    required: true
    index: 'text'
  transliterated:
    type: String
    unique: true
  text:
    type: String
    required: true
    index: 'text'
  updated:
    type: Date
    required: true
    default: moment
  created:
    type: Date
    required: true
    default: -> moment().format()
    set: (date) -> moment(date, 'DD/MM/YYYY').format()
  author:
    author_id:
      type: ObjectId
      ref: 'Client'
    name:
      type: String
  specialist:
    owner_id:
      type: Number
    specialist_id:
      type: ObjectId
      ref: 'User'
    name:
      type: String
  active:
    type: Boolean
    required: true
    default: true
  closed:
    type: Boolean
    default: false
  recommended:
    type: Boolean
    default: false
  encyclopedia:
    type: Boolean
    default: false
  position:
    type: Number
    default: 0
  hasBigView:
    type: Boolean
    default: false
  type:
    name:
      type: String
  age: [
    _id:
      type: ObjectId
      ref: "Age"
      set: mongoose.Types.ObjectId
      sparse: true
    title:
      type: String
    fixture:
      type: String
  ]
  theme: [
    _id:
      type: ObjectId
      ref: "Theme"
      set: mongoose.Types.ObjectId
      sparse: true
    name:
      type: String
    position:
      type: Number
      default: 0
    hasBigView:
      type: Boolean
      default: false
  ]
  likes: [
    client:
      type: ObjectId
      ref: 'Client'
  ]
  watchers: [
    type: ObjectId
    ref: 'Client'
  ]
  answer: [
    _id:
      type: ObjectId
      default: mongoose.Types.ObjectId
    author:
      author_id:
        type: ObjectId
        ref: 'Client'
      name:
        type: String
    specialist:
      owner_id:
        type: Number
      _id:
        type: ObjectId
        ref: 'User'
      name:
        type: String
    date:
      type: Date
      default: moment
    text:
      type: String
      required: true
    parent:
      type: ObjectId
    counter:
      type: Number
      default: 0
  ],
  counter:
    like:
      type: Number
      default: 0
    watch:
      type: Number
      default: 0
,
  collection: 'consultation'

schema.pre 'save', (next) ->
  this.updated = moment()
  this.transliterated = translit
    .transliterate this.name
    .replace /\s/g, '_'
    .replace /[^\w\d_]/g, ''

  next()

module.exports = mongoose.model 'Consultation', schema
