describe ActiveRecord::VirtualAttributes::VirtualIncludes do
  before do
    Author.destroy_all
    Book.destroy_all
    Author.create_with_books(3).books.first.create_bookmarks(2)
  end

  let(:author_name) { "foo" }
  let(:book_name) { "bar" }
  # NOTE: each of the 1 authors has an array of books. so this value is [[Book, Book]]
  let(:named_books) { [Book.where.not(:name => nil).order(:id).load] }

  context "preloads virtual_attributes with includes" do
    it "preloads virtual_attribute (:uses => nil) (with a NO OP)" do
      expect(Author.includes(:nick_or_name)).to preload_values(:nick_or_name, author_name)
      expect(Author.includes([:nick_or_name])).to preload_values(:nick_or_name, author_name)
      expect(Author.includes(:nick_or_name => {})).to preload_values(:nick_or_name, author_name)
    end

    it "preloads virtual_attribute (delegate defines :uses => :author)" do
      expect(Book.includes(:author_name)).to preload_values(:author_name, author_name)
    end

    it "preloads virtual_attribute (multiple)" do
      expect(Author.includes([:nick_or_name, :first_book_name])).to preload_values(:first_book_name, book_name)
      expect(Author.includes(:nick_or_name => {}, :first_book_name => {})).to preload_values(:first_book_name, book_name)
    end

    it "preloads virtual_attribute (:uses => {:book => :author_name})" do
      expect(Author.includes(:first_book_author_name => {})).to preload_values(:first_book_author_name, author_name)
    end

  end

  context "virtual reflection" do
    it "as Symbol" do
      expect(Author.includes(:named_books)).to preload_values(:named_books, named_books)
    end

    it "as Array" do
      expect(Author.includes([:named_books])).to preload_values(:named_books, named_books)
      expect(Author.includes([:named_books, :bookmarks])).to preload_values(:named_books, named_books)
    end

    it "as Hash" do
      expect(Author.includes(:named_books => {})).to preload_values(:named_books, named_books)
      expect(Author.includes(:named_books => {}, :bookmarks => :book)).to preload_values(:named_books, named_books)
    end
  end

  it "should handle virtual fields in :include when :conditions are also present in calculations" do
    expect(Book.includes([:author_name, :author]).references(:author).where("authors.name = 'test'")).to preload_values(:author_name, author_name)
    expect(Book.includes([:author_name, :author]).references(:author).where("authors.id IS NOT NULL")).to preload_values(:author_name, author_name)
  end

  it "should fetch virtual fields without includes" do
    expect(Book.select(:author_name)).to preload_values(:author_name, author_name)
  end

  it "should fetch virtual field using references" do
    skip("AR 5.1 not including properly") if ActiveRecord.version.to_s >= "5.1"
    expect(Book.includes(:author_name).references(:author_name)).to preload_values(:author_name, author_name)
  end

  it "should fetch virtual field using all 3" do
    skip("AR 5.1 not including properly") if ActiveRecord.version.to_s >= "5.1"
    expect(Book.select(:author_name).includes(:author_name).references(:author_name)).to preload_values(:author_name, author_name)
  end
end
